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
import { Categories, CompanyLocations, Role, Users } from '@prisma/client';
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
  SignInDto,
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
      const {
        createCandidateDto,
        createRecruiterDto,
        playerId,
        platform,
        deviceInfo,
        ...res
      } = signUpDto;

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
        .upsert(
          [
            {
              ...res,
              ID: data.user.id,
              Password: hashedPassword,
              AvatarUrl: this.configService.get<string>(
                'default_logo_user',
                '',
              ),
            },
          ],
          {
            onConflict: 'Email',
          },
        )
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
        const { Position, companyID, companyLocationID } = createRecruiterDto;

        const { data: company } = await this.anonSupabaseClient
          .from('Companies')
          .select('*, CompanyLocations(*)')
          .eq('ID', companyID)
          .maybeSingle<any>();

        if (!company)
          throw new NotFoundException(
            `Không tìm thấy công ty có id '${companyID}' trong hệ thống.`,
          );

        const { data: companyLocation } = await this.anonSupabaseClient
          .from('CompanyLocations')
          .select('*')
          .eq('ID', companyLocationID)
          .maybeSingle<CompanyLocations>();

        if (!companyLocation)
          throw new NotFoundException(
            `Không tìm thấy chi nhánh công ty có id '${companyLocationID}' trong hệ thống.`,
          );

        if (
          company.CompanyLocations.map((cl: any) => cl.ID)?.includes(
            companyLocationID,
          )
        )
          throw new BadRequestException(
            `Chi nhánh '${companyLocation.BranchName}' không thuộc về công ty '${company.Name}'`,
          );

        await this.createRecruiterUser(
          userData.ID,
          Position,
          companyLocationID,
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
          EmailSupport: this.configService.get<string>('admin.email', ''),
          PhoneSupport: this.configService.get<string>(
            'admin.phone_number',
            '',
          ),
          ApplicationLogoUrl: this.configService.get<string>(
            'application.logo_url',
            '',
          ),
        },
      );

      if (playerId && platform && deviceInfo)
        await this.handleVerifyDeviceOfUser(
          playerId,
          platform,
          deviceInfo,
          userData.ID,
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

  async signIn(signInDto: SignInDto) {
    try {
      const { email, password, playerId, platform, deviceInfo } = signInDto;

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
            {
              otp,
              FullName: findUser.FullName,
              EmailSupport: this.configService.get<string>('admin.email', ''),
              PhoneSupport: this.configService.get<string>(
                'admin.phone_number',
                '',
              ),
              ApplicationLogoUrl: this.configService.get<string>(
                'application.logo_url',
                '',
              ),
            },
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

      if (playerId && platform && deviceInfo)
        await this.handleVerifyDeviceOfUser(
          playerId,
          platform,
          deviceInfo,
          data.user.id,
        );

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

      if (error) {
        console.error(error);

        throw new UnauthorizedException(
          'Bạn đã cung cấp refresh token hết hạn. Vui lòng đăng nhập lại để nhận refresh token mới.',
        );
      }

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

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          `Đã xảy ra lỗi khi cập nhật trạng thái xác minh cho email '${email}'.`,
        );
      }

      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('Email', email)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có email '${email}' trong hệ thống.`,
        );

      await this.emailsProducer.sendEmail(
        email,
        EmailTemplateNameEnum.EMAIL_REGISTER_ACCOUNT_SUCCESS,
        {
          FullName: findUser.FullName,
          EmailSupport: this.configService.get<string>('admin.email', ''),
          PhoneSupport: this.configService.get<string>(
            'admin.phone_number',
            '',
          ),
          ApplicationLogoUrl: this.configService.get<string>(
            'application.logo_url',
            '',
          ),
          Role: user.Role === Role.candidate ? 'candidate' : 'recruiter',
        },
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

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình lấy ra các tỉnh thành. Vui lòng thử lại.',
        );
      }

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

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình lấy ra tên các công ty. Vui lòng thử lại sau.',
        );
      }

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
          EmailSupport: this.configService.get<string>('admin.email', ''),
          PhoneSupport: this.configService.get<string>(
            'admin.phone_number',
            '',
          ),
          ApplicationLogoUrl: this.configService.get<string>(
            'application.logo_url',
            '',
          ),
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
          EmailSupport: this.configService.get<string>('admin.email', ''),
          PhoneSupport: this.configService.get<string>(
            'admin.phone_number',
            '',
          ),
          ApplicationLogoUrl: this.configService.get<string>(
            'application.logo_url',
            '',
          ),
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
  }

  private createCandidateUser = async (
    userId: string,
    createCandidateDto: CreateCandidateDto,
  ) => {
    const { error } = await this.adminSupabaseClient.from('Candidates').upsert(
      [
        {
          ...createCandidateDto,
          UserID: userId,
        },
      ],
      {
        onConflict: 'UserID',
      },
    );

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi đăng ký tài khoản ứng viên.',
      );
    }
  };

  private createRecruiterUser = async (
    userId: string,
    position: string,
    companyLocationId: string,
  ) => {
    const { error } = await this.adminSupabaseClient.from('Recruiters').upsert(
      [
        {
          Position: position,
          UserID: userId,
          CompanyLocationID: companyLocationId,
        },
      ],
      {
        onConflict: 'UserID',
      },
    );

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi đăng ký tài khoản nhà tuyển dụng.',
      );
    }
  };

  public createCompany = async (createCompanyDto: CreateCompanyDto) => {
    const { createCompanyLocationDto, ...res } = createCompanyDto;

    const { data, error } = await this.adminSupabaseClient
      .from('Companies')
      .upsert([res], {
        onConflict: 'Name',
      })
      .select('*, CompanyLocations(*)')
      .single<any>();

    if (error || !data) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi tạo mới công ty.',
      );
    }

    await this.createCompanyLocation(
      createCompanyLocationDto,
      data.ID as string,
    );

    return (
      await this.anonSupabaseClient
        .from('Companies')
        .select('*, CompanyLocations(*)')
        .eq('Name', res.Name)
    )?.data;
  };

  private createCompanyLocation = async (
    createCompanyLocationDto: CreateCompanyLocationDto,
    companyId: string,
  ) => {
    const { LocationID, ...res } = createCompanyLocationDto;

    const { error } = await this.adminSupabaseClient
      .from('CompanyLocations')
      .upsert(
        [
          {
            ...res,
            CompanyID: companyId,
            LocationID,
          },
        ],
        {
          onConflict: 'BranchName, CompanyID',
        },
      );

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi tạo mới chi nhánh làm việc của công ty.',
      );
    }
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

      if (!company) throw new NotFoundException(`Không tìm thấy công ty này.`);

      const { BranchName, Address, LocationID } = createCompanyLocationDto;

      const { data: existingBranch, error: errorExistingBranch } =
        await this.anonSupabaseClient
          .from('CompanyLocations')
          .select('*')
          .match({ BranchName, CompanyID: companyId })
          .maybeSingle<CompanyLocations>();

      if (errorExistingBranch) {
        console.error(errorExistingBranch);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi tìm kiếm chi nhánh của công ty.',
        );
      }

      if (existingBranch)
        throw new BadRequestException('Chi nhánh đã tồn tại trong công ty.');

      const { error: errorCreateBranch } = await this.adminSupabaseClient
        .from('CompanyLocations')
        .insert([
          {
            BranchName,
            Address,
            LocationID,
            CompanyID: companyId,
          },
        ]);

      if (errorCreateBranch) {
        console.error(errorCreateBranch);

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

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy thông tin các danh mục công việc.',
        );
      }

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

      if (insertCategoryError) {
        console.error(insertCategoryError);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm danh mục công việc mới vào hệ thống.',
        );
      }

      return this.jobsService.handleGetCategories();
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private handleVerifyDeviceOfUser = async (
    playerId: string,
    platform: string,
    deviceInfo: string,
    userId: string,
  ) => {
    const { error } = await this.anonSupabaseClient.from('UserDevices').upsert(
      [
        {
          UserID: userId,
          PlayerID: playerId,
          Platform: platform,
          DeviceInfo: deviceInfo,
        },
      ],
      { onConflict: 'UserID, PlayerID' },
    );

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi trong quá trình kiểm tra thiết bị của người dùng đăng nhập.',
      );
    }
  };
}
