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
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { Request } from 'express';
import { FileValidationDecorator, Roles } from 'src/libs/common/decorators';
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
  UpdatePasswordDto,
  VerifyEmailDto,
  VerifyResetPasswordOtpDto,
} from 'src/modules/auth/dtos';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('sign-in')
  async signIn(@Body() { email, password }: SignInDto) {
    return this.authService.signIn(email, password);
  }

  @Post('sign-up')
  @UseInterceptors(
    FileFieldsInterceptor([
      {
        name: 'avatar',
        maxCount: 1,
      },
      {
        name: 'resumeFile',
        maxCount: 1,
      },
      {
        name: 'logoFile',
        maxCount: 1,
      },
    ]),
  )
  async signUp(
    @Body() signUpDto: SignUpDto,
    @FileValidationDecorator()
    files?: {
      avatar?: Express.Multer.File[];
      resumeFile?: Express.Multer.File[];
      logoFile?: Express.Multer.File[];
    },
  ) {
    return this.authService.signUp(
      signUpDto,
      files?.avatar ? files.avatar[0] : undefined,
      files?.resumeFile ? files.resumeFile[0] : undefined,
      files?.logoFile ? files.logoFile[0] : undefined,
    );
  }

  @Post('verify-email')
  async verifyEmail(@Body() verifyEmailDto: VerifyEmailDto) {
    return this.authService.handleVerifyEmail(verifyEmailDto);
  }

  @Post('refresh-token')
  async handleRefreshToken(@Body('refreshToken') refreshToken: string) {
    return this.authService.refreshToken(refreshToken);
  }

  @Post('sign-out')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  async signOut() {
    return this.authService.signOut();
  }

  @Get('profile')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
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
  async getProvinces() {
    return this.authService.getProvinces();
  }

  @Get('companies')
  async getCompanies() {
    return this.authService.getCompanies();
  }

  @Post('forget-password')
  async forgetPassword(@Body() { email }: ForgetPasswordDto) {
    return this.authService.handleForgetPassword(email);
  }

  @Post('verify-reset-password-otp')
  async verifyResetPasswordOtp(
    @Body() verifyResetPasswordOtpDto: VerifyResetPasswordOtpDto,
  ) {
    return this.authService.handleVerifyResetPasswordOtp(
      verifyResetPasswordOtpDto,
    );
  }

  @Post('reset-password')
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.handleResetPassword(resetPasswordDto);
  }

  @Post('update-password')
  async updatePassword(@Body() updatePasswordDto: UpdatePasswordDto) {
    return this.authService.handleUpdatePassword(updatePasswordDto);
  }
}
