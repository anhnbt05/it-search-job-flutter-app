import { CacheInterceptor, CacheTTL } from '@nestjs/cache-manager';
import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard, SupabaseGuard } from 'src/libs/common/guards';
import {
  API_TAGS,
  DEFAULT_TTL_PROVINCES_CACHE,
  RoleEnum,
} from 'src/libs/common/utils';
import {
  CreateCategoryDto,
  ForgetPasswordDto,
  ResetPasswordDto,
  SignInDto,
  SignUpDto,
  VerifyEmailDto,
  VerifyResetPasswordOtpDto,
} from 'src/modules/auth/dtos';
import { CreateCompanyLocationDto } from 'src/modules/users/dtos';
import { AuthService } from './auth.service';

@Controller('auth')
@ApiTags(API_TAGS.AUTH)
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('sign-in')
  @ApiOperation({
    summary: 'Đăng nhập',
    description: 'Đường dẫn dành cho việc đăng nhập.',
  })
  @ApiBody({
    type: SignInDto,
    examples: {
      example1: {
        summary: 'Dữ liệu đăng nhập đầu vào hợp lệ.',
        value: {
          email: 'lengocanhpyne363@gamil.com',
          password: 'user123',
        },
      },
      example2: {
        summary: 'Dữ liệu đăng nhập đầu vào không hợp lệ.',
        value: {
          email: 'lengocanhpyne363@gamil.com',
        },
      },
      example3: {
        summary: 'Dữ liệu đăng nhập đầu vào không hợp lệ.',
        value: {
          password: 'pass123',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        accessToken: 'eyJhbGciOiJIUzI1NiIsIm...',
        refreshToken: 'eyJhbGciOiJIUzI1NiIsIm...',
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: '',
    schema: {
      example: {
        message: 'Thông tin đăng nhập không chính xác.',
        error: 'Không xác thực được người dùng.',
        statusCode: 401,
      },
    },
  })
  async signIn(@Body() { email, password }: SignInDto) {
    return this.authService.signIn(email, password);
  }

  @Post('sign-up')
  @ApiOperation({
    summary: 'Đăng ký',
    description: 'Đường dẫn dành cho việc việc đăng ký tài khoản mới.',
  })
  @ApiBody({
    type: SignUpDto,
    description: 'Các thông tin cần gửi để đăng ký tài khoản',
  })
  @ApiResponse({
    status: 400,
    description:
      'Không hiểu yêu cầu (vd, thiếu trường dữ liệu, dữ liệu gửi đi không đúng kiểu dữ liệu.)',
    schema: {
      example: {
        message: "Người dùng có số điện thoại '+84393873630' đã tồn tại.",
        error: 'Không hiểu yêu cầu.',
        statusCode: 400,
      },
    },
  })
  @ApiResponse({
    status: 500,
    description: 'Lỗi từ hệ thống.',
  })
  @ApiBody({
    type: SignUpDto,
    description: `Phần thân của yêu cầu này được sử dụng để đăng ký người dùng. Trường 'Role' sẽ quyết định xem có cần thêm thông tin chi tiết về nhà tuyển dụng hoặc ứng viên hay không.`,
    examples: {
      candidate: {
        summary: 'Dữ liệu mẫu cho việc đăng ký ứng viên mới.',
        value: {
          Email: 'lengocanhpyne363@gmail.com',
          Password: 'StrongPassword123',
          FullName: 'Lê Ngọc Anh',
          PhoneNumber: '+84393873630',
          Role: 'candidate',
          createCandidateDto: {
            Bio: 'Kỹ sư phần mềm với hơn 3 năm kinh nghiệm với React.js',
            Level: 'mid',
            Certifications: [
              'AWS Certified Developer',
              'Google Cloud Associate',
            ],
          },
        },
      },
      recruiter: {
        summary: 'Dữ liệu mẫu 1 cho việc đăng ký nhà tuyển dụng mới.',
        value: {
          Email: 'recruiter@gmail.com',
          Password: 'StrongPassword123',
          FullName: 'Lê Văn Nam',
          PhoneNumber: '+84393873631',
          Role: 'recruiter',
          createRecruiterDto: {
            Position: 'Nhân sự',
            companyID: '550e8400-e29b-41d4-a716-446655440000',
          },
        },
      },
      recruiter1: {
        summary: 'Dữ liệu mẫu 2 cho việc đăng ký nhà tuyển dụng mới.',
        value: {
          Email: 'recruiter@example.com',
          Password: 'StrongPassword123',
          FullName: 'Lê Văn Nam',
          PhoneNumber: '+84393873632',
          Role: 'recruiter',
          createRecruiterDto: {
            Position: 'Trưởng phòng nhân sự',
            createCompanyDto: {
              Name: 'Công ty Công nghệ ABC',
              WebsiteUrl: 'https://techcorp.com',
              Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
              createCompanyLocationDto: {
                BranchName: 'Trụ sở chính',
                Address:
                  '1234 Khu phố 1, Đường Phạm Văn Đồng, Thành phố Hồ Chí Minh, Việt Nam.',
                LocationID: 'c12a45f7-9b32-4c3d-b589-8dfaa2a2c55e',
              },
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        success: true,
        message:
          'Chúng tôi đã gửi mã OTP xác thực đến email của bạn. Vui lòng nhập mã để hoàn tất quá trình xác thực.',
      },
    },
  })
  async signUp(@Body() signUpDto: SignUpDto) {
    return this.authService.signUp(signUpDto);
  }

  @Post('verify-email')
  @ApiOperation({ summary: 'Xác thực email người dùng với mã OTP.' })
  @ApiBody({
    type: VerifyEmailDto,
    description: 'Cung cấp email và mã OTP nhận được từ email đó.',
    examples: {
      example1: {
        summary: 'Dữ liệu gửi đi hợp lệ.',
        value: {
          email: 'user@example.com',
          otp: '123456',
        },
      },
      example2: {
        summary: 'Dữ liệu gửi đi không hợp lệ.',
        value: {
          email: 'hello123@gmail.com',
        },
      },
      example3: {
        summary: 'Dữ liệu gửi đi không hợp lệ.',
        value: {
          otp: '123456',
        },
      },
    },
  })
  @ApiCreatedResponse({
    schema: {
      example: {
        success: true,
        message:
          'Email của bạn đã được xác thực thành công. Bạn có thể đăng nhập ngay bây giờ.',
      },
    },
  })
  async verifyEmail(@Body() verifyEmailDto: VerifyEmailDto) {
    return this.authService.handleVerifyEmail(verifyEmailDto);
  }

  @Post('refresh-token')
  @ApiOperation({ summary: 'Làm mới access token nếu nó hết hạn' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        refreshToken: {
          type: 'string',
          example: 'your-refresh-token-here',
        },
      },
    },
    description: 'Gửi một refresh token hợp lệ để nhận được access token mới.',
  })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        accessToken: '.....',
      },
    },
  })
  async handleRefreshToken(@Body('refreshToken') refreshToken: string) {
    return this.authService.refreshToken(refreshToken);
  }

  @Post('sign-out')
  @UseGuards(SupabaseGuard, RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Đăng xuất',
    description:
      'Đường dẫn này dùng để đăng xuất tài khoản người dùng ra khỏi hệ thống.',
  })
  @ApiResponse({
    status: 200,
    description: 'Đăng xuất thành công',
    schema: {
      example: { success: true, message: 'Đăng xuất tài khoản thành công.' },
    },
  })
  @ApiResponse({ status: 401, description: 'Người dùng không xác thực.' })
  async signOut() {
    return this.authService.signOut();
  }

  @Get('provinces')
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(DEFAULT_TTL_PROVINCES_CACHE)
  @ApiOperation({
    summary: 'Danh sách các tỉnh, thành phố',
    description: 'Đường dẫn này dùng để lấy ra danh sách các tỉnh, thành phố',
  })
  @ApiResponse({
    status: 200,
    description: 'Danh sách các tỉnh, thành phố',
    schema: {
      example: [
        {
          ID: '123f7d52-dfc9-480c-9352-6b57a708f95f',
          Name: 'Thành phố Hà Nội',
        },
        {
          ID: '4ed34a88-4554-46cd-a0ef-d98194eb86b5',
          Name: 'Tỉnh Hà Giang',
        },
        {
          ID: '79a7ad67-1a3f-4611-a90b-e9e8f60e30b9',
          Name: 'Tỉnh Cao Bằng',
        },
        {
          ID: '8a16ae4b-a247-4363-8383-4585e0e0ad2e',
          Name: 'Tỉnh Bắc Kạn',
        },
      ],
    },
  })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getProvinces() {
    return this.authService.getProvinces();
  }

  @Get('companies')
  @ApiOperation({
    summary: 'Danh sách các công ty',
    description:
      'Đường dẫn này dùng để lấy ra danh sách các công ty hiện có trong hệ thống.',
  })
  @ApiResponse({
    status: 200,
    description: 'Danh sách các công ty',
    schema: {
      example: [
        {
          ID: '123f7d52-dfc9-480c-9352-6b57a708f95f',
          Name: 'FPT Software',
        },
        {
          ID: '4ed34a88-4554-46cd-a0ef-d98194eb86b5',
          Name: 'VNG',
        },
        {
          ID: '79a7ad67-1a3f-4611-a90b-e9e8f60e30b9',
          Name: 'Công ty Công nghệ ABC',
        },
        {
          ID: '8a16ae4b-a247-4363-8383-4585e0e0ad2e',
          Name: 'Công ty TNHH Technology Việt Nam',
        },
      ],
    },
  })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getCompanies() {
    return this.authService.getCompanies();
  }

  @Post('forget-password')
  @ApiOperation({
    summary: 'Quên mật khẩu',
    description:
      'Đường dẫn này hỗ trợ cấp lại mật khẩu mới nếu như lỡ quên mật khẩu hiện tại.',
  })
  @ApiBody({
    type: ForgetPasswordDto,
    description: 'Gửi email đã liên kết tài khoản cần đặt mới mật khẩu',
    examples: {
      example1: {
        summary: 'Dữ liệu gửi đi hợp lệ.',
        value: {
          email: 'user@example.com',
        },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Email không đúng định dạng hoặc không gửi đi email.',
  })
  @ApiResponse({ status: 500, description: 'Lỗi từ hệ thống.' })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        success: true,
        message: 'OTP đã được gửi tới email.',
      },
    },
  })
  async forgetPassword(@Body() { email }: ForgetPasswordDto) {
    return this.authService.handleForgetPassword(email);
  }

  @Post('verify-reset-password-otp')
  @ApiOperation({ summary: 'Xác thực OTP cho email' })
  @ApiBody({
    type: VerifyResetPasswordOtpDto,
    description:
      'Xác thực mã OTP đã gửi đến email của người dùng để đặt lại mật khẩu.',
    examples: {
      example1: {
        summary: 'Dữ liệu gửi đi hợp lệ.',
        value: {
          email: 'user@example.com',
          otp: '123456',
        },
      },
      example2: {
        summary: 'Dữ liệu gửi đi không hợp lệ.',
        value: {
          email: 'user@example.com',
        },
      },
      example3: {
        summary: 'Dữ liệu gửi đi không hợp lệ.',
        value: {
          otp: '123456',
        },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Mã OTP hoặc email không hợp lệ' })
  @ApiResponse({ status: 500, description: 'Lỗi từ hệ thống.' })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        success: true,
        message: 'OTP hợp lệ. Bạn có thể chuyển đến bưỡc tiếp theo.',
      },
    },
  })
  async verifyResetPasswordOtp(
    @Body() verifyResetPasswordOtpDto: VerifyResetPasswordOtpDto,
  ) {
    return this.authService.handleVerifyResetPasswordOtp(
      verifyResetPasswordOtpDto,
    );
  }

  @Post('reset-password')
  @ApiOperation({ summary: 'Đặt lại mật khẩu với mật khẩu mới.' })
  @ApiBody({
    type: ResetPasswordDto,
    description: 'Yêu cầu đặt lại mật khẩu bằng mật khẩu mới và email.',
    examples: {
      example1: {
        summary: 'Dữ liệu gửi đi hợp lệ.',
        value: {
          email: 'user@example.com',
          newPassword: 'NewSecurePassword123',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Password reset successfully',
    example: {
      success: true,
      message:
        'Đặt lại mật khẩu thành công. Bây giờ, bạn có thể dùng mật khẩu mới để đăng nhập.',
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Email hoặc mật khẩu không đúng định dạng.',
  })
  @ApiResponse({ status: 500, description: 'Lỗi từ hệ thống.' })
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.handleResetPassword(resetPasswordDto);
  }

  @Get('companies/:companyId/branches')
  @ApiOperation({
    summary: 'Danh sách các chi nhánh của các công ty trong hệ thống',
    description:
      'Đường dẫn này dùng để lấy ra danh sách các chi nhánh của các công ty trong hệ thống.',
  })
  async getBranchesOfCompany(
    @Param('companyId', ParseUUIDPipe) companyId: string,
  ) {
    return this.authService.handleGetBranchesOfCompany(companyId);
  }

  @Post('companies/:companyId/branches')
  @ApiOperation({
    summary: 'Tạo mới chi nhánh cho công ty',
    description: 'Đường dẫn này dùng để tạo mới một chi nhánh cho công ty.',
  })
  @ApiBody({
    type: CreateCompanyLocationDto,
    description: 'Dữ liệu cần gửi đi để tạo mới chi nhánh cho công ty.',
  })
  async createBranchOfCompany(
    @Param('companyId', ParseUUIDPipe) companyId: string,
    @Body() createCompanyLocationDto: CreateCompanyLocationDto,
  ) {
    return this.authService.handleCreateBranchOfCompany(
      companyId,
      createCompanyLocationDto,
    );
  }

  @Get('categories')
  @UseGuards(SupabaseGuard, RoleAuthGuard)
  @ApiOperation({
    summary: 'Danh sách các danh mục công việc',
    description:
      'Đường dẫn này dùng để lấy ra danh sách các danh mục của công việc.',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: '944bc899-557e-437c-95c7-556cef67d8bb',
          CategoryName: 'Front End',
        },
        {
          ID: '0dbad36a-f140-4406-97eb-a85aba15c3ee',
          CategoryName: 'Embedded Engineer',
        },
        {
          ID: '0f16e89f-ba50-4b16-a37f-584a399a6a2f',
          CategoryName: 'Cyber Security',
        },
        {
          ID: 'a24032b0-61fc-4918-b3f2-25e4fe0711d7',
          CategoryName: 'UI/UX Designer',
        },
      ],
    },
  })
  @ApiBearerAuth()
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  async getCategories() {
    return this.authService.handleGetCategories();
  }

  @Post('categories')
  @UseGuards(SupabaseGuard, RoleAuthGuard)
  @ApiOperation({
    summary: 'Tạo mới danh mục công việc',
    description: 'Đường dẫn này dùng để tạo mới danh mục công việc',
  })
  @ApiForbiddenResponse({
    description: 'Chỉ có quản trị viên mới có quyền tạo mới danh mục',
  })
  @ApiResponse({
    status: 201,
    schema: {
      example: [
        {
          ID: '944bc899-557e-437c-95c7-556cef67d8bb',
          CategoryName: 'Front End',
        },
        {
          ID: '0dbad36a-f140-4406-97eb-a85aba15c3ee',
          CategoryName: 'Embedded Engineer',
        },
        {
          ID: '0f16e89f-ba50-4b16-a37f-584a399a6a2f',
          CategoryName: 'Cyber Security',
        },
        {
          ID: 'a24032b0-61fc-4918-b3f2-25e4fe0711d7',
          CategoryName: 'UI/UX Designer',
        },
      ],
    },
  })
  @ApiBody({
    type: CreateCategoryDto,
    description: 'Dữ liệu cần gửi đi để tạo mới danh mục.',
  })
  @Roles(RoleEnum.ADMIN)
  @ApiBearerAuth()
  async createCategory(@Body() createCategoryDto: CreateCategoryDto) {
    return this.authService.handleCreateCategory(createCategoryDto);
  }
}
