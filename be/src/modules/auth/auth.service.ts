import { Cache, CACHE_MANAGER } from '@nestjs/cache-manager';
import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Categories, Companies, CompanyLocation, Users } from '@prisma/client';
import { SupabaseClient, User } from '@supabase/supabase-js';
import { omit } from 'lodash';
import {
  DEFAULT_MAX_ATTEMPTS,
  DEFAULT_TTL_OTP_EXPIRED,
  DEFAULT_VERIFIED_OTP_RESET_PASSWORD,
  EmailTemplateNameEnum,
  generateOTP,
  hashPassword,
  RoleEnum,
} from 'src/libs/common/utils';
import {
  CreateCategoryDto,
  ResetPasswordDto,
  SignUpDto,
  VerifyEmailDto,
  VerifyResetPasswordOtpDto,
} from 'src/modules/auth/dtos';
import { EmailsProducer } from 'src/modules/emails/producers';
import { JobsService } from 'src/modules/jobs/jobs.service';
import { SupabaseService } from 'src/modules/supabase/supabase.service';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import {
  CreateCandidateDto,
  CreateCompanyDto,
  CreateCompanyLocationDto,
  CreateRecruiterDto,
} from 'src/modules/users/dtos';

@Injectable()
export class AuthService {
  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly configService: ConfigService,
    @Inject(CACHE_MANAGER) private readonly cacheManager: Cache,
    private readonly emailsProducer: EmailsProducer,
    private readonly jobsService: JobsService,
  ) {}

  async signUp(signUpDto: SignUpDto) {
    try {
      const { createCandidateDto, createRecruiterDto, ...res } = signUpDto;

      const { Password, Email, PhoneNumber, Role } = res;

      this.validateRoleData(res.Role, createCandidateDto, createRecruiterDto);

      const supabase = this.supabaseService.getClient();

      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data: findUserWithEmail } = await supabaseAdmin
        .from('Users')
        .select('*')
        .eq('Email', Email)
        .single<Users | null>();

      if (findUserWithEmail)
        throw new BadRequestException(
          `User with email '${Email}' has already existed.`,
        );

      const { data: findUserWithPhoneNumber } = await supabaseAdmin
        .from('Users')
        .select('*')
        .eq('PhoneNumber', PhoneNumber)
        .single<Users | null>();

      if (findUserWithPhoneNumber)
        throw new BadRequestException(
          `User with phone number '${PhoneNumber}' has already existed.`,
        );

      const hashedPassword = hashPassword(res.Password);

      const { data, error } = await supabase.auth.signUp({
        email: Email,
        password: Password,
      });

      if (!data.user) throw new UnauthorizedException('User creation failed');

      if (error) throw new UnauthorizedException(error.message);

      await supabaseAdmin.auth.admin.updateUserById(data.user.id, {
        app_metadata: {
          role: Role,
        },
      });

      const { data: userData, error: dbError } = await supabaseAdmin
        .from('Users')
        .insert([
          {
            ...res,
            ID: data.user.id,
            Password: hashedPassword,
            AvatarUrl: this.configService.get<string>('default_logo_user', ''),
          },
        ])
        .select('*')
        .single<Users>();

      if (dbError) throw new Error(dbError.message);

      if (Role === RoleEnum.CANDIDATE && createCandidateDto) {
        await this.createCandidateUser(
          userData.ID,
          createCandidateDto,
          supabaseAdmin,
        );
      }

      if (Role === RoleEnum.RECRUITER && createRecruiterDto) {
        const { createCompanyDto, createExistingCompanyDto, Position } =
          createRecruiterDto;

        if (createCompanyDto && createExistingCompanyDto)
          throw new BadRequestException(
            'You must provide either createExistingCompanyDto or createCompanyDto, not both.',
          );

        let createCompanyLocationId = '';

        if (createExistingCompanyDto) {
          const { companyLocationID } = createExistingCompanyDto;

          createCompanyLocationId = companyLocationID;
        } else if (createCompanyDto) {
          const { companyLocationId } = await this.createCompany(
            createCompanyDto,
            supabaseAdmin,
          );

          createCompanyLocationId = companyLocationId;
        }

        await this.createRecruiterUser(
          userData.ID,
          Position,
          supabaseAdmin,
          createCompanyLocationId,
        );
      }

      const otp = generateOTP();

      await this.cacheManager.set(
        `${Email}:otp-verify-email`,
        otp,
        DEFAULT_TTL_OTP_EXPIRED,
      );

      await this.emailsProducer.sendEmail(
        Email,
        EmailTemplateNameEnum.EMAIL_VERIFICATION,
        {
          otp,
          FullName: signUpDto.FullName,
        },
      );

      return {
        success: true,
        message:
          'We have sent a verification OTP to your email. Please enter it to complete verification.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  }

  async signIn(email: string, password: string) {
    try {
      const supabase = this.supabaseService.getClient();

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) throw new UnauthorizedException(error.message);

      const { data: findUser } = await supabase
        .from('Users')
        .select('*')
        .eq('ID', data.user.id)
        .single<Users | null>();

      if (!findUser)
        throw new NotFoundException(
          `User with id: '${data.user.id}' not found.`,
        );

      if (!findUser.IsEmailVerified) {
        if (
          !(await this.cacheManager.get(`${findUser.Email}:otp-verify-email`))
        ) {
          const otp = generateOTP();

          await this.cacheManager.set(
            `${findUser.Email}:otp-verify-email`,
            otp,
            DEFAULT_TTL_OTP_EXPIRED,
          );

          await this.emailsProducer.sendEmail(
            `${findUser.Email}`,
            EmailTemplateNameEnum.EMAIL_VERIFICATION,
            { otp, FullName: findUser.FullName },
          );

          return {
            message:
              'We have sent a verification OTP to your email. Please enter it to complete verification.',
          };
        }

        throw new ForbiddenException(
          'Please check the OTP sent to your email to complete verification before logging in.',
        );
      }

      return {
        accessToken: data?.session?.access_token,
        refreshToken: data?.session?.refresh_token,
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  }

  public signOut = async () => {
    try {
      const supabase = this.supabaseService.getClient();

      await supabase.auth.signOut();

      return { success: true, message: 'Logged out successfully' };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  async refreshToken(refreshToken: string) {
    try {
      const supabase = this.supabaseService.getClient();

      const { data, error } = await supabase.auth.refreshSession({
        refresh_token: refreshToken,
      });

      if (error) throw new UnauthorizedException(error.message);

      return {
        accessToken: data?.session?.access_token,
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  }

  public handleVerifyEmail = async (verifyEmailDto: VerifyEmailDto) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { email, otp } = verifyEmailDto;

      const { data: findUser } = await supabaseAdmin
        .from('Users')
        .select('*')
        .eq('Email', email)
        .single<Users | null>();

      if (!findUser)
        throw new NotFoundException(
          `User with email '${email}' not found in the system.`,
        );

      const otpInRedisCache = await this.cacheManager.get(
        `${email}:otp-verify-email`,
      );

      if (!otpInRedisCache)
        throw new UnauthorizedException(
          `OTP has expired. Please request a new code.`,
        );

      const maxAttempts = DEFAULT_MAX_ATTEMPTS;

      const attempts =
        Number(
          (await this.cacheManager.get(`${email}:otp-attempts`)) as string,
        ) || 0;

      if (attempts >= maxAttempts)
        throw new ForbiddenException(
          'Too many failed attempts. Please request a new OTP.',
        );

      if (otpInRedisCache !== otp) {
        await this.cacheManager.set(
          `${email}:otp-attempts`,
          attempts + 1,
          120000,
        );

        throw new BadRequestException(
          `Invalid OTP. You have ${maxAttempts - (attempts + 1)} attempts remaining.`,
        );
      }

      await this.cacheManager.del(`${email}:otp-verify-email`);

      await this.cacheManager.del(`${email}:otp-attempts`);

      const { error } = await supabaseAdmin
        .from('Users')
        .update({ IsEmailVerified: true })
        .eq('Email', email);

      if (error)
        throw new Error(
          `Failed to update email verified status: ${error.message}`,
        );

      await this.emailsProducer.sendEmail(
        email,
        EmailTemplateNameEnum.EMAIL_REGISTER_ACCOUNT_SUCCESS,
        { FullName: findUser.FullName },
      );

      return {
        success: true,
        message:
          'Your email has been successfully verified. You can now log in.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetProfile = async (userId: string) => {
    try {
      const supabase = this.supabaseService.getClient();

      const { error, data } = await supabase
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .single<Users | null>();

      if (error) throw error;

      return omit(data as Users, ['Password']);
    } catch (err) {
      console.error(err);
    }
  };

  public getProvinces = async () => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data, error } = await supabaseAdmin
        .from('Locations')
        .select('ID, Name');

      if (error) throw new Error(error.message);

      return data;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public getCompanies = async () => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data, error } = await supabaseAdmin
        .from('Companies')
        .select('ID, Name');

      if (error) throw error;

      return data;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleForgetPassword = async (email: string) => {
    try {
      const otp = generateOTP();

      const supabase = this.supabaseService.getClient();

      const { data, error } = await supabase
        .from('Users')
        .select('*')
        .eq('Email', email)
        .single<Users | null>();

      if (error)
        throw new NotFoundException(
          `User with email '${email}' not found in the system.`,
        );

      await this.cacheManager.set(`${email}:otp-reset-password`, otp);

      await this.emailsProducer.sendEmail(
        email,
        EmailTemplateNameEnum.EMAIL_RESET_PASSWORD,
        {
          otp,
          FullName: (data as Users).FullName,
        },
      );

      return {
        success: true,
        message: 'Password reset email sent successfully.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleVerifyResetPasswordOtp = async (
    verifyResetPasswordDto: VerifyResetPasswordOtpDto,
  ) => {
    const { email, otp } = verifyResetPasswordDto;

    const otpInRedisCache = await this.cacheManager.get(
      `${email}:otp-reset-password`,
    );

    if (!otpInRedisCache)
      throw new UnauthorizedException(
        `OTP has expired. Please request a new code.`,
      );

    const maxAttempts = DEFAULT_MAX_ATTEMPTS;

    const attempts =
      Number(
        (await this.cacheManager.get(`${email}:otp-attempts`)) as string,
      ) || 0;

    if (attempts >= maxAttempts)
      throw new ForbiddenException(
        'Too many failed attempts. Please request a new OTP.',
      );

    if (otpInRedisCache !== otp) {
      await this.cacheManager.set(
        `${email}:otp-attempts`,
        attempts + 1,
        120000,
      );

      throw new BadRequestException(
        `Invalid OTP. You have ${maxAttempts - (attempts + 1)} attempts remaining.`,
      );
    }

    await this.cacheManager.set(
      `${email}:otp-verified-reset-password`,
      true,
      DEFAULT_VERIFIED_OTP_RESET_PASSWORD,
    );

    return {
      success: true,
      message: 'Valid OTP.',
    };
  };

  public handleResetPassword = async (resetPasswordDto: ResetPasswordDto) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { newPassword, email } = resetPasswordDto;

      const { data, error } = await supabaseAdmin
        .from('Users')
        .select('FullName')
        .eq('Email', email)
        .single<Users | null>();

      if (error) throw new Error(error.message);

      const isHavePermissionToResetPassword = (await this.cacheManager.get(
        `${email}:otp-verified-reset-password`,
      )) as boolean;

      if (!isHavePermissionToResetPassword)
        throw new BadRequestException(
          'Please verify the OTP sent to your email before proceeding with the password reset.',
        );

      await this.updatePassword(supabaseAdmin, email, newPassword);

      await this.cacheManager.del(`${email}:otp-reset-password`);

      await this.cacheManager.del(`${email}:otp-attempts`);

      await this.cacheManager.del(`${email}:otp-verified-reset-password`);

      await this.emailsProducer.sendEmail(
        email,
        EmailTemplateNameEnum.EMAIL_UPDATE_PASSWORD_SUCCESS,
        {
          FullName: (data as Users).FullName,
        },
      );

      return {
        success: true,
        message:
          'Your password has been reset successfully. You can now log in with your new password.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private updatePassword = async (
    supabaseAdmin: SupabaseClient,
    email: string,
    newPassword: string,
  ) => {
    const { data: userData } = await supabaseAdmin.auth.admin.listUsers();

    const existingUser = userData.users.find(
      (user: User) => user.email === email,
    );

    if (!existingUser)
      throw new NotFoundException(
        `User with email: '${email}' not found in the system.`,
      );

    const { error } = await supabaseAdmin.auth.admin.updateUserById(
      existingUser.id,
      {
        password: newPassword,
      },
    );

    if (error) throw new Error(error.message);

    const hashedPassword = hashPassword(newPassword);

    await supabaseAdmin
      .from('Users')
      .update([
        {
          Password: hashedPassword,
        },
      ])
      .eq('Email', email);
  };

  private validateRoleData(
    role: 'candidate' | 'recruiter',
    createCandidateDto?: CreateCandidateDto,
    createRecruiterDto?: CreateRecruiterDto,
  ) {
    if (role === RoleEnum.CANDIDATE && !createCandidateDto) {
      throw new BadRequestException(
        'Candidate details must be provided when registering as a candidate.',
      );
    }

    if (role === RoleEnum.RECRUITER && !createRecruiterDto) {
      throw new BadRequestException(
        'Recruiter details must be provided when registering as a recruiter.',
      );
    }

    if (
      role === RoleEnum.RECRUITER &&
      createRecruiterDto &&
      !createRecruiterDto?.createExistingCompanyDto &&
      !createRecruiterDto?.createCompanyDto
    )
      throw new BadRequestException('Missing recruiter company information.');
  }

  private createCandidateUser = async (
    userId: string,
    createCandidateDto: CreateCandidateDto,
    supabaseAdmin: SupabaseClient,
  ) => {
    const { error } = await supabaseAdmin.from('Candidates').insert([
      {
        ...createCandidateDto,
        UserID: userId,
      },
    ]);

    if (error) throw error;
  };

  private createRecruiterUser = async (
    userId: string,
    position: string,
    supabaseAdmin: SupabaseClient,
    companyLocationId: string,
  ) => {
    const { error } = await supabaseAdmin.from('Recruiters').insert([
      {
        Position: position,
        UserID: userId,
        CompanyLocationID: companyLocationId,
      },
    ]);

    if (error) throw error;
  };

  private createCompany = async (
    createCompanyDto: CreateCompanyDto,
    supabaseAdmin: SupabaseClient,
  ) => {
    const { createCompanyLocationDto, ...res } = createCompanyDto;

    const { data, error } = await supabaseAdmin
      .from('Companies')
      .insert([res])
      .select('*')
      .single<Companies | null>();

    if (error) throw error;

    const companyLocationId = await this.createCompanyLocation(
      createCompanyLocationDto,
      (data as Companies).ID,
      supabaseAdmin,
    );

    return {
      company: data as Companies,
      companyLocationId,
    };
  };

  private createCompanyLocation = async (
    createCompanyLocationDto: CreateCompanyLocationDto,
    companyId: string,
    supabaseAdmin: SupabaseClient,
  ) => {
    const { LocationID, ...res } = createCompanyLocationDto;

    const { data, error } = await supabaseAdmin
      .from('CompanyLocation')
      .insert([
        {
          ...res,
          CompanyID: companyId,
          LocationID,
        },
      ])
      .select('*')
      .maybeSingle<CompanyLocation>();

    if (error) throw error;

    if (!data) throw new Error(`Error when creating new company location.`);

    return data.ID;
  };

  public handleGetBranchesOfCompany = async (companyId: string) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data: company } = await supabaseAdmin
        .from('Companies')
        .select('*, CompanyLocation(*)')
        .eq('ID', companyId)
        .maybeSingle<any>();

      if (!company)
        throw new NotFoundException(
          `Không tìm thấy công ty có id '${companyId}'.`,
        );

      return company?.CompanyLocation;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleCreateBranchOfCompany = async (
    companyId: string,
    createCompanyLocationDto: CreateCompanyLocationDto,
  ) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data: company } = await supabaseAdmin
        .from('Companies')
        .select('*, CompanyLocation(*)')
        .eq('ID', companyId)
        .maybeSingle<any>();

      if (!company)
        throw new NotFoundException(
          `Không tìm thấy công ty có id '${companyId}'.`,
        );

      const { BranchName, Address, LocationID } = createCompanyLocationDto;

      const { error } = await supabaseAdmin.from('CompanyLocation').upsert(
        [
          {
            BranchName,
            Address,
            LocationID,
            CompanyID: companyId,
          },
        ],
        { onConflict: 'BranchName,CompanyID' },
      );

      if (error) throw error;

      return (
        await supabaseAdmin
          .from('Companies')
          .select('*, CompanyLocation(*)')
          .eq('ID', companyId)
          .maybeSingle<any>()
      ).data.CompanyLocation;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetCategories = async () => {
    return this.jobsService.handleGetCategories();
  };

  public handleCreateCategory = async (
    createCategoryDto: CreateCategoryDto,
  ) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { CategoryName } = createCategoryDto;

      const { data, error } = await supabaseAdmin
        .from('Categories')
        .select('*')
        .eq('CategoryName', CategoryName)
        .maybeSingle<Categories>();

      if (error) throw error;

      if (data)
        throw new BadRequestException(
          `Danh mục có tên '${CategoryName}' đã tồn tại.`,
        );

      const { error: insertCategoryError } = await supabaseAdmin
        .from('Categories')
        .insert([
          {
            CategoryName,
          },
        ]);

      if (insertCategoryError) throw insertCategoryError;

      return this.jobsService.handleGetCategories();
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
