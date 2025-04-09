import { Cache, CACHE_MANAGER } from '@nestjs/cache-manager';
import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Categories, Companies, CompanyLocations, Users } from '@prisma/client';
import { SupabaseClient, User } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
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
import {
  CreateCandidateDto,
  CreateCompanyDto,
  CreateCompanyLocationDto,
  CreateRecruiterDto,
} from 'src/modules/users/dtos';

@Injectable()
export class AuthService {
  constructor(
    private readonly configService: ConfigService,
    @Inject(CACHE_MANAGER) private readonly cacheManager: Cache,
    private readonly emailsProducer: EmailsProducer,
    private readonly jobsService: JobsService,
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
  ) {}

  async signUp(signUpDto: SignUpDto) {
    try {
      const { createCandidateDto, createRecruiterDto, ...res } = signUpDto;

      const { Password, Email, PhoneNumber, Role } = res;

      this.validateRoleData(res.Role, createCandidateDto, createRecruiterDto);

      const { data: findUserWithEmail } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('Email', Email)
        .single<Users | null>();

      if (findUserWithEmail)
        throw new BadRequestException(
          `Đã có người dùng sử dụng email '${Email}.'`,
        );

      const { data: findUserWithPhoneNumber } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('PhoneNumber', PhoneNumber)
        .single<Users | null>();

      if (findUserWithPhoneNumber)
        throw new BadRequestException(
          `Đã có người dùng sử dụng số điện thoại '${PhoneNumber}'.`,
        );

      const hashedPassword = hashPassword(res.Password);

      const { data } = await this.anonSupabaseClient.auth.signUp({
        email: Email,
        password: Password,
      });

      if (!data.user)
        throw new UnauthorizedException(
          'Tạo mới người dùng không thành công. Vui lòng thử lại.',
        );

      await this.adminSupabaseClient.auth.admin.updateUserById(data.user.id, {
        app_metadata: {
          role: Role,
        },
      });

      const { data: userData, error: dbError } = await this.adminSupabaseClient
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

      if (dbError)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình tạo mới người dùng.',
        );

      if (Role === RoleEnum.CANDIDATE && createCandidateDto) {
        await this.createCandidateUser(userData.ID, createCandidateDto);
      }

      if (Role === RoleEnum.RECRUITER && createRecruiterDto) {
        const { createCompanyDto, createExistingCompanyDto, Position } =
          createRecruiterDto;

        if (createCompanyDto && createExistingCompanyDto)
          throw new BadRequestException(
            'Bạn phải cung cấp hoặc createExistingCompanyDto hoặc createCompanyDto, chứ không phải cả hai.',
          );

        let createCompanyLocationId = '';

        if (createExistingCompanyDto) {
          const { companyLocationID } = createExistingCompanyDto;

          createCompanyLocationId = companyLocationID;
        } else if (createCompanyDto) {
          const { companyLocationId } =
            await this.createCompany(createCompanyDto);

          createCompanyLocationId = companyLocationId;
        }

        await this.createRecruiterUser(
          userData.ID,
          Position,
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
          'Chúng tôi đã gửi mã OTP xác minh đến email của bạn. Vui lòng nhập mã để hoàn tất quá trình xác minh.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  }

  async signIn(email: string, password: string) {
    try {
      const { data, error } =
        await this.adminSupabaseClient.auth.signInWithPassword({
          email,
          password,
        });

      if (error) {
        console.error(error);

        throw new BadRequestException(
          'Thông tin đăng nhập không chính xác. Vui lòng thử lại.',
        );
      }

      const { data: findUser } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', data.user.id)
        .single<Users | null>();

      if (!findUser)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${data.user.id}' trong hệ thống.`,
        );

      if (findUser.Status === 'inactive')
        throw new ForbiddenException(
          'Tài khoản của bạn đã bị khoá bởi quản trị viên trong hệ thống. Vui lòng liên hệ với họ để biết thêm thông tin.',
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
              'Chúng tôi đã gửi mã OTP xác minh đến email của bạn. Vui lòng nhập mã để hoàn tất quá trình xác minh.',
          };
        }

        throw new ForbiddenException(
          'Vui lòng kiểm tra mã OTP đã được gửi đến email của bạn để hoàn tất xác minh trước khi đăng nhập.',
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
      await this.adminSupabaseClient.auth.signOut();

      return { success: true, message: 'Đăng xuất tài khoản thành công.' };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  async refreshToken(refreshToken: string) {
    try {
      const { data, error } =
        await this.adminSupabaseClient.auth.refreshSession({
          refresh_token: refreshToken,
        });

      if (error)
        throw new UnauthorizedException(
          'Bạn đã cung cấp refresh token hết hạn. Vui lòng đăng nhập lại để nhận refresh token mới.',
        );

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
      const { email, otp } = verifyEmailDto;

      const { data: findUser } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('Email', email)
        .single<Users | null>();

      if (!findUser)
        throw new NotFoundException(
          `Không tìm thấy người dùng có email '${email}' trong hệ thống.`,
        );

      if (findUser.Status === 'inactive')
        throw new ForbiddenException(
          `Tài khoản liên kết với email '${email}' đã bị khoá bởi quản trị viên trong hệ thống.`,
        );

      const otpInRedisCache = await this.cacheManager.get(
        `${email}:otp-verify-email`,
      );

      if (!otpInRedisCache)
        throw new UnauthorizedException(
          `Mã OTP này đã hết hạn. Vui lòng yêu cầu mã OTP mới.`,
        );

      const maxAttempts = DEFAULT_MAX_ATTEMPTS;

      const attempts =
        Number(
          (await this.cacheManager.get(`${email}:otp-attempts`)) as string,
        ) || 0;

      if (attempts >= maxAttempts)
        throw new ForbiddenException(
          'Mã OTP đã bị vô hiệu hoá do bạn đã nhập sai quá nhiều lần. Vui lòng yêu cầu mã OTP mới.',
        );

      if (otpInRedisCache !== otp) {
        await this.cacheManager.set(
          `${email}:otp-attempts`,
          attempts + 1,
          120000,
        );

        throw new BadRequestException(
          `Mã OTP không hợp lệ. Bạn còn lại ${maxAttempts - (attempts + 1)} lần thử.`,
        );
      }

      await this.cacheManager.del(`${email}:otp-verify-email`);

      await this.cacheManager.del(`${email}:otp-attempts`);

      const { error } = await this.adminSupabaseClient
        .from('Users')
        .update({ IsEmailVerified: true })
        .eq('Email', email);

      if (error)
        throw new InternalServerErrorException(
          `Đã xảy ra lỗi khi cập nhật trạng thái xác minh cho email '${email}'.`,
        );

      await this.emailsProducer.sendEmail(
        email,
        EmailTemplateNameEnum.EMAIL_REGISTER_ACCOUNT_SUCCESS,
        { FullName: findUser.FullName },
      );

      return {
        success: true,
        message:
          'Email của bạn đã được xác minh thành công. Bây giờ bạn có thể đăng nhập.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public getProvinces = async () => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Locations')
        .select('ID, Name');

      if (error)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình lấy ra các tỉnh thành. Vui lòng thử lại.',
        );

      return data;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public getCompanies = async () => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Companies')
        .select('ID, Name');

      if (error)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình lấy ra tên các công ty. Vui lòng thử lại sau.',
        );

      return data;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleForgetPassword = async (email: string) => {
    try {
      const otp = generateOTP();

      const { data } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('Email', email)
        .single<Users | null>();

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy người dùng có email '${email}' trong hệ thống.`,
        );

      await this.cacheManager.set(`${email}:otp-reset-password`, otp);

      await this.emailsProducer.sendEmail(
        email,
        EmailTemplateNameEnum.EMAIL_RESET_PASSWORD,
        {
          otp,
          FullName: data.FullName,
        },
      );

      return {
        success: true,
        message: 'OTP đã được gửi tới email.',
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
        `Mã OTP này đã hết hạn. Vui lòng yêu cầu mã OTP mới.`,
      );

    const maxAttempts = DEFAULT_MAX_ATTEMPTS;

    const attempts =
      Number(
        (await this.cacheManager.get(`${email}:otp-attempts`)) as string,
      ) || 0;

    if (attempts >= maxAttempts)
      throw new ForbiddenException(
        'Mã OTP đã bị vô hiệu hoá do bạn nhập sai quá nhiều. Vui lòng yêu cầu mã OTP mới.',
      );

    if (otpInRedisCache !== otp) {
      await this.cacheManager.set(
        `${email}:otp-attempts`,
        attempts + 1,
        120000,
      );

      throw new BadRequestException(
        `Mã OTP không hợp lệ. Bạn còn ${maxAttempts - (attempts + 1)} lần thử.`,
      );
    }

    await this.cacheManager.set(
      `${email}:otp-verified-reset-password`,
      true,
      DEFAULT_VERIFIED_OTP_RESET_PASSWORD,
    );

    return {
      success: true,
      message: 'OTP hợp lệ. Bạn có thể chuyển đến bưỡc tiếp theo.',
    };
  };

  public handleResetPassword = async (resetPasswordDto: ResetPasswordDto) => {
    try {
      const { newPassword, email } = resetPasswordDto;

      const { data, error } = await this.anonSupabaseClient
        .from('Users')
        .select('FullName')
        .eq('Email', email)
        .maybeSingle<Users>();

      if (!data || error) {
        console.error(error);

        throw new InternalServerErrorException(
          `Không tìm thấy người dùng có email '${email}' trong hệ thống.`,
        );
      }

      const isHavePermissionToResetPassword = (await this.cacheManager.get(
        `${email}:otp-verified-reset-password`,
      )) as boolean;

      if (!isHavePermissionToResetPassword)
        throw new BadRequestException(
          'Please verify the OTP sent to your email before proceeding with the password reset.',
        );

      await this.updatePassword(email, newPassword);

      await this.cacheManager.del(`${email}:otp-reset-password`);

      await this.cacheManager.del(`${email}:otp-attempts`);

      await this.cacheManager.del(`${email}:otp-verified-reset-password`);

      await this.emailsProducer.sendEmail(
        email,
        EmailTemplateNameEnum.EMAIL_UPDATE_PASSWORD_SUCCESS,
        {
          FullName: data.FullName,
        },
      );

      return {
        success: true,
        message:
          'Đặt lại mật khẩu thành công. Bây giờ, bạn có thể dùng mật khẩu mới để đăng nhập.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private updatePassword = async (email: string, newPassword: string) => {
    const { data: userData } =
      await this.adminSupabaseClient.auth.admin.listUsers();

    const existingUser = userData.users.find(
      (user: User) => user.email === email,
    );

    if (!existingUser)
      throw new NotFoundException(
        `Không tìm thấy người dùng có email '${email}' trong hệ thống.`,
      );

    const { error } = await this.adminSupabaseClient.auth.admin.updateUserById(
      existingUser.id,
      {
        password: newPassword,
      },
    );

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi cập nhật mật khẩu người dùng.',
      );
    }

    const hashedPassword = hashPassword(newPassword);

    await this.adminSupabaseClient
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
        'Thông tin ứng viên phải được cung cấp khi đăng ký làm ứng viên.',
      );
    }

    if (role === RoleEnum.RECRUITER && !createRecruiterDto) {
      throw new BadRequestException(
        'Thông tin nhà tuyển dụng phải được cung cấp khi đăng ký làm nhà tuyển dụng.',
      );
    }

    if (
      role === RoleEnum.RECRUITER &&
      createRecruiterDto &&
      !createRecruiterDto?.createExistingCompanyDto &&
      !createRecruiterDto?.createCompanyDto
    )
      throw new BadRequestException('Vui lòng cung cấp thông tin về công ty.');
  }

  private createCandidateUser = async (
    userId: string,
    createCandidateDto: CreateCandidateDto,
  ) => {
    const { error } = await this.adminSupabaseClient.from('Candidates').insert([
      {
        ...createCandidateDto,
        UserID: userId,
      },
    ]);

    if (error)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi đăng ký tài khoản ứng viên.',
      );
  };

  private createRecruiterUser = async (
    userId: string,
    position: string,
    companyLocationId: string,
  ) => {
    const { error } = await this.adminSupabaseClient.from('Recruiters').insert([
      {
        Position: position,
        UserID: userId,
        CompanyLocationID: companyLocationId,
      },
    ]);

    if (error)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi đăng ký tài khoản nhà tuyển dụng.',
      );
  };

  private createCompany = async (createCompanyDto: CreateCompanyDto) => {
    const { createCompanyLocationDto, ...res } = createCompanyDto;

    const { data, error } = await this.adminSupabaseClient
      .from('Companies')
      .insert([res])
      .select('*')
      .single<Companies | null>();

    if (error) throw error;

    const companyLocationId = await this.createCompanyLocation(
      createCompanyLocationDto,
      (data as Companies).ID,
    );

    return {
      company: data as Companies,
      companyLocationId,
    };
  };

  private createCompanyLocation = async (
    createCompanyLocationDto: CreateCompanyLocationDto,
    companyId: string,
  ) => {
    const { LocationID, ...res } = createCompanyLocationDto;

    const { data, error } = await this.adminSupabaseClient
      .from('CompanyLocations')
      .insert([
        {
          ...res,
          CompanyID: companyId,
          LocationID,
        },
      ])
      .select('*')
      .maybeSingle<CompanyLocations>();

    if (error || !data)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi tạo mới chi nhánh làm việc của công ty.',
      );

    return data.ID;
  };

  public handleGetBranchesOfCompany = async (companyId: string) => {
    try {
      const { data: company } = await this.anonSupabaseClient
        .from('Companies')
        .select('*, CompanyLocations(*)')
        .eq('ID', companyId)
        .maybeSingle<any>();

      if (!company)
        throw new NotFoundException(
          `Không tìm thấy công ty có id '${companyId}'.`,
        );

      return company?.CompanyLocations;
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
      const { data: company } = await this.anonSupabaseClient
        .from('Companies')
        .select('*, CompanyLocations(*)')
        .eq('ID', companyId)
        .maybeSingle<any>();

      if (!company)
        throw new NotFoundException(
          `Không tìm thấy công ty có id '${companyId}'.`,
        );

      const { BranchName, Address, LocationID } = createCompanyLocationDto;

      const { error } = await this.adminSupabaseClient
        .from('CompanyLocations')
        .upsert(
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

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi tạo mới địa điểm làm việc của công ty.',
        );
      }

      return (
        await this.anonSupabaseClient
          .from('Companies')
          .select('*, CompanyLocations(*)')
          .eq('ID', companyId)
          .maybeSingle<any>()
      ).data.CompanyLocations;
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
      const { CategoryName } = createCategoryDto;

      const { data, error } = await this.anonSupabaseClient
        .from('Categories')
        .select('*')
        .eq('CategoryName', CategoryName)
        .maybeSingle<Categories>();

      if (error) throw error;

      if (data)
        throw new BadRequestException(
          `Danh mục có tên '${CategoryName}' đã tồn tại.`,
        );

      const { error: insertCategoryError } = await this.adminSupabaseClient
        .from('Categories')
        .insert([
          {
            CategoryName,
          },
        ]);

      if (insertCategoryError)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm danh mục công việc mới vào hệ thống.',
        );

      return this.jobsService.handleGetCategories();
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
