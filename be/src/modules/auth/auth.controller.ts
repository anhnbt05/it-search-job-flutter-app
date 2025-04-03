import { CacheInterceptor, CacheTTL } from '@nestjs/cache-manager';
import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  UnauthorizedException,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiCreatedResponse,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { Request } from 'express';
import { Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard } from 'src/libs/common/guards';
import {
  DEFAULT_TTL_PROVINCES_CACHE,
  RoleEnum,
  SupabaseUserToken,
} from 'src/libs/common/utils';
import {
  ForgetPasswordDto,
  ResetPasswordDto,
  SignInDto,
  SignUpDto,
  VerifyEmailDto,
  VerifyResetPasswordOtpDto,
} from 'src/modules/auth/dtos';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('sign-in')
  @ApiOperation({
    summary: 'User sign-in',
    description:
      'This endpoint allows a user to sign in using their credentials and returns an access token and refresh token for authentication.',
  })
  @ApiBody({
    type: SignInDto,
    examples: {
      example1: {
        summary: 'Valid Sign in dto',
        value: {
          email: 'lengocanhpyne363@gamil.com',
          password: 'user123',
        },
      },
      example2: {
        summary: 'Invalid Sign in dto',
        value: {
          email: 'lengocanhpyne363@gamil.com',
        },
      },
      example3: {
        summary: 'Invalid Sign in dto',
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
        message: 'Invalid login credentials',
        error: 'Unauthorized',
        statusCode: 401,
      },
    },
  })
  async signIn(@Body() { email, password }: SignInDto) {
    return this.authService.signIn(email, password);
  }

  @Post('sign-up')
  @ApiOperation({
    summary: 'User sign-up',
    description:
      'This endpoint allows a new user to register as either a recruiter or a candidate. Recruiters can optionally provide company details.',
  })
  @ApiBody({
    type: SignUpDto,
    description:
      'User registration details. The role field determines whether additional recruiter or candidate information is required.',
  })
  @ApiResponse({
    status: 400,
    description:
      'Bad request (e.g., missing required fields or invalid data format).',
    schema: {
      example: {
        message: "User with phone number '+84393873630' has already existed.",
        error: 'Bad Request',
        statusCode: 400,
      },
    },
  })
  @ApiResponse({
    status: 500,
    description: 'Internal server error.',
  })
  @ApiBody({
    type: SignUpDto,
    description:
      'This request body is used for user registration. The "Role" field determines whether additional recruiter or candidate details are required.',
    examples: {
      candidate: {
        summary: 'Candidate Sign-up Example',
        value: {
          Email: 'candidate@example.com',
          Password: 'StrongPassword123',
          FullName: 'John Doe',
          PhoneNumber: '+84393873630',
          Role: 'candidate',
          createCandidateDto: {
            Bio: 'Software developer with 3 years of experience in frontend development.',
            Level: 'mid',
            Certifications: [
              'AWS Certified Developer',
              'Google Cloud Associate',
            ],
          },
        },
      },
      recruiter: {
        summary: 'Recruiter Sign-up Example 1',
        value: {
          Email: 'recruiter@example.com',
          Password: 'StrongPassword123',
          FullName: 'Jane Smith',
          PhoneNumber: '+84393873630',
          Role: 'recruiter',
          createRecruiterDto: {
            Position: 'HR Manager',
            companyID: '550e8400-e29b-41d4-a716-446655440000',
          },
        },
      },
      recruiter1: {
        summary: 'Recruiter Sign-up Example 2',
        value: {
          Email: 'recruiter@example.com',
          Password: 'StrongPassword123',
          FullName: 'Jane Smith',
          PhoneNumber: '+84393873630',
          Role: 'recruiter',
          createRecruiterDto: {
            Position: 'HR Manager',
            createCompanyDto: {
              Name: 'Tech Corp',
              WebsiteUrl: 'https://techcorp.com',
              Description: 'A leading tech company',
              createCompanyLocationDto: {
                BranchName: 'Headquarters',
                Address: '1234 Silicon Valley, CA, USA',
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
          'We have sent a verification OTP to your email. Please enter it to complete verification.',
      },
    },
  })
  async signUp(@Body() signUpDto: SignUpDto) {
    return this.authService.signUp(signUpDto);
  }

  @Post('verify-email')
  @ApiOperation({ summary: 'Verify email using OTP' })
  @ApiBody({
    type: VerifyEmailDto,
    description: 'Provide the email and the 6-digit OTP received.',
    examples: {
      example1: {
        summary: 'Successful verification',
        value: {
          email: 'user@example.com',
          otp: '123456',
        },
      },
      example2: {
        summary: 'Unsuccessful verification',
        value: {
          email: 'hello123@gmail.com',
        },
      },
      example3: {
        summary: 'Unsuccessful verification',
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
          'Your email has been successfully verified. You can now log in.',
      },
    },
  })
  async verifyEmail(@Body() verifyEmailDto: VerifyEmailDto) {
    return this.authService.handleVerifyEmail(verifyEmailDto);
  }

  @Post('refresh-token')
  @ApiOperation({ summary: 'Refresh access token' })
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
    description: 'Send a valid refresh token to get a new access token.',
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
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Sign out user' })
  @ApiResponse({
    status: 200,
    description: 'User signed out successfully',
    schema: {
      example: { success: true, message: 'Logged out successfully' },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async signOut() {
    return this.authService.signOut();
  }

  @Get('profile')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user profile' })
  @ApiResponse({
    status: 200,
    description: 'User profile retrieved successfully',
    schema: {
      example: {
        ID: '550e8400-e29b-41d4-a716-446655440000',
        Email: 'user@example.com',
        FullName: 'John Doe',
        PhoneNumber: '+84393873630',
        Status: 'active',
        AvatarUrl: 'https://...',
        Role: 'candidate',
        CreatedAt: '2025-03-20T15:15:15Z',
        UpdatedAt: '2025-03-20T15:15:15Z',
        DeletedAt: null,
        IsEmailVerified: false,
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized: User not authenticated',
  })
  async getProfile(@Req() request: Request) {
    if (!request.user)
      throw new UnauthorizedException(`User not authenticated.`);

    return this.authService.handleGetProfile(
      (request.user as SupabaseUserToken).id,
    );
  }

  @Get('provinces')
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(DEFAULT_TTL_PROVINCES_CACHE)
  @ApiOperation({ summary: 'Get list of provinces' })
  @ApiResponse({
    status: 200,
    description: 'List of provinces retrieved successfully',
    schema: {
      example: [
        { ID: '1', Name: 'Thành phố Hà Nội' },
        { ID: '2', Name: 'Tỉnh Phú Yên' },
      ],
    },
  })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getProvinces() {
    return this.authService.getProvinces();
  }

  @Get('companies')
  @ApiOperation({ summary: 'Get list of companies' })
  @ApiResponse({
    status: 200,
    description: 'List of companies retrieved successfully',
    schema: {
      example: [
        { ID: '1', Name: 'Tech Corp' },
        { ID: '2', Name: 'Innovate Ltd' },
      ],
    },
  })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getCompanies() {
    return this.authService.getCompanies();
  }

  @Post('forget-password')
  @ApiOperation({ summary: 'Request password reset' })
  @ApiBody({
    type: ForgetPasswordDto,
    description: 'Send an email to reset the password',
    examples: {
      example1: {
        summary: 'Valid email request',
        value: {
          email: 'user@example.com',
        },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid email format or missing email',
  })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        success: true,
        message: 'Password reset email sent successfully.',
      },
    },
  })
  async forgetPassword(@Body() { email }: ForgetPasswordDto) {
    return this.authService.handleForgetPassword(email);
  }

  @Post('verify-reset-password-otp')
  @ApiOperation({ summary: 'Verify OTP for password reset' })
  @ApiBody({
    type: VerifyResetPasswordOtpDto,
    description: 'Verify the OTP sent to the user’s email for password reset',
    examples: {
      example1: {
        summary: 'Valid OTP verification request',
        value: {
          email: 'user@example.com',
          otp: '123456',
        },
      },
      example2: {
        summary: 'Invalid OTP verification request',
        value: {
          email: 'user@example.com',
        },
      },
      example3: {
        summary: 'Invalid OTP verification request',
        value: {
          otp: '123456',
        },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid OTP or email format' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        success: true,
        message: 'Valid OTP.',
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
  @ApiOperation({ summary: 'Reset password with a new password' })
  @ApiBody({
    type: ResetPasswordDto,
    description: 'Request to reset password using a new password and email',
    examples: {
      example1: {
        summary: 'Valid reset password request',
        value: {
          email: 'user@example.com',
          newPassword: 'NewSecurePassword123',
        },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Password reset successfully' })
  @ApiResponse({ status: 400, description: 'Invalid email or password format' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.handleResetPassword(resetPasswordDto);
  }
}
