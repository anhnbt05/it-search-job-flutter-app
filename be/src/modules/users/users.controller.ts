import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Query,
  Req,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiBody,
  ApiExtraModels,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { FileValidationDecorator, Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard, SupabaseGuard } from 'src/libs/common/guards';
import { API_TAGS, RoleEnum } from 'src/libs/common/utils';
import {
  DeleteUserQueryDto,
  SearchUsersDto,
  UpdateCandidateDto,
  UpdateRecruiterDto,
  UpdateUserDto,
} from 'src/modules/users/dtos';
import { UsersService } from './users.service';

@Controller('users')
@UseGuards(SupabaseGuard, RoleAuthGuard)
@ApiBearerAuth()
@ApiTags(API_TAGS.USER)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles(RoleEnum.ADMIN)
  @ApiOperation({
    summary:
      'Lấy ra danh sách tất cả các người dùng (ứng viên, nhà tuyển dụng) trong hệ thống.',
    description:
      'Đường dẫn này dùng để lấy ra danh sách tất cả các người dùng (ứng viên, nhà tuyển dụng) trong hệ thống. Chỉ có quản trị viên mới có quyền truy cập.',
  })
  @ApiResponse({
    status: 200,
    description: 'Dữ liệu trả về sau khi lấy danh sách người dùng thành công.',
    examples: {
      example1: {
        summary:
          'Trường hợp lấy toàn bộ danh sách người dùng (không dùng /?candidateId= hoặc /?recruiterId=)',
        value: [
          {
            ID: '674c7204-106e-4d7f-8dc3-3f6389d0aa8e',
            Email: 'lengocanhpyne363@gmail.com',
            FullName: 'Lê Văn Nam',
            AvatarUrl:
              'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
            PhoneNumber: '+84393873632',
            Status: 'active',
            CreatedAt: '2025-04-06T15:51:31.508',
            UpdatedAt: '2025-04-06T15:51:31.508',
            Role: 'recruiter',
            DeletedAt: null,
            IsEmailVerified: true,
          },
          {
            ID: 'ee40a614-0e80-48bf-b69d-7987d6bedc4c',
            Email: 'lamduannhi0508@gmail.com',
            FullName: 'Lê Ngọc Anh',
            AvatarUrl:
              'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
            PhoneNumber: '+84393873631',
            Status: 'active',
            CreatedAt: '2025-04-06T15:49:08.349',
            UpdatedAt: '2025-04-06T15:49:08.349',
            Role: 'candidate',
            DeletedAt: null,
            IsEmailVerified: true,
          },
        ],
      },
      example2: {
        summary: 'Trường hợp lọc theo query recruiterId (/?recruiterId=...)',
        value: {
          ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          Position: 'Trưởng phòng nhân sự',
          FullName: 'Lê Văn Nam',
          Email: 'lengocanhpyne363@gmail.com',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          PhoneNumber: '+84393873632',
          IsEmailVerified: true,
          Company: {
            ID: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
            Name: 'Công ty ABC',
            LogoUrl: null,
            CreatedAt: '2025-04-06T15:51:31.73',
            UpdatedAt: '2025-04-06T15:51:31.73',
            WebsiteUrl: 'https://techcorp.com',
            Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
          },
          CompanyLocations: {
            ID: '3119455f-0091-47f9-8ec4-0f7db3ada5bb',
            Address:
              '1234 Khu phố 1, Đường Phạm Văn Đồng, Thành phố Hồ Chí Minh, Việt Nam.',
            CreatedAt: '2025-04-06T15:51:31.895',
            UpdatedAt: '2025-04-06T15:51:31.895',
            BranchName: 'Trụ sở chính',
          },
        },
      },
      example3: {
        summary: 'Trường hợp lọc theo query candidateId (/?candidateId=...)',
        value: {
          ID: '891addf9-d54d-4c88-852d-fe96cb295536',
          ResumeUrl: null,
          Certifications: ['AWS Certified Developer', 'Google Cloud Associate'],
          Bio: 'Software developer with 3 years of experience in frontend development.',
          Level: 'senior',
          FullName: 'Lê Ngọc Anh',
          Email: 'lamduannhi0508@gmail.com',
          PhoneNumber: '+84393873631',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          Role: 'candidate',
          WorkExperiences: [
            {
              ID: 'fddf389e-a341-46bb-9c52-0a1f818c738f',
              EndDate: '2025-02-20T00:00:00',
              JobType: 'remote',
              Location: 'Phường 7, Quận Thủ Đức, TP. HCM',
              Position: 'Backend Developer',
              StartDate: '2024-11-01T08:00:00',
              CompanyName: 'Công ty KMS Technology',
              Descriptions: [
                'Viết API cho hệ thống backend',
                'Dùng framework NestJS để tăng khả năng mở rộng cho hệ thống',
              ],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744071950209-kms-tech.png',
            },
            {
              ID: 'f8df1734-259b-4cb1-b33f-dd0e299b7be3',
              EndDate: '2024-10-01T00:00:00',
              JobType: 'part_time',
              Location: 'Phường 7, Quận Thủ Đức, TP. HCM',
              Position: 'Frontend Developer',
              StartDate: '2024-05-01T08:00:00',
              CompanyName: 'Công ty KMS Technology',
              Descriptions: [
                'Thiết kế giao diện dùng Figma',
                'Dùng framework Next.js để viết giao diện',
              ],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744071580455-kms-tech.png',
            },
            {
              ID: '35910e7c-bcbf-4d0e-a260-cd4d59dd26f8',
              EndDate: null,
              JobType: 'part_time',
              Location: 'Quận Thủ Đức, TP. HCM',
              Position: 'Kỹ sư phần mềm',
              StartDate: '2024-05-01T08:00:00',
              CompanyName: 'Công ty phần mềm ABC',
              Descriptions: ['Viết NestJS', 'Dùng PostgreSQL'],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744070730106-logo-fpt-software_043151683.png',
            },
            {
              ID: '01c17e17-b4b2-4f5a-a12b-c843f257b586',
              EndDate: '2021-12-15T00:00:00',
              JobType: 'part_time',
              Location: 'Mountain View, California',
              Position: 'Lập trình viên Frontend',
              StartDate: '2020-06-01T00:00:00',
              CompanyName: 'Google',
              Descriptions: [
                'Xây dựng giao diện người dùng phản hồi bằng React',
                'Cải thiện hiệu năng lên 30%',
                'Hợp tác với các nhà thiết kế UX',
              ],
              CompanyLogoUrl: 'https://logo.clearbit.com/google.com',
            },
          ],
          Applications: [
            {
              ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
              JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
              Status: 'pending',
              AppliedAt: '2025-04-07T07:33:55.337',
              DeletedAt: null,
              ResumeUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
              CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
            },
            {
              ID: 'cbcbeab7-b6ba-4c03-a9b0-58fe0de6b138',
              JobID: 'e9a4b957-3e7e-48c8-b88e-fd26d83ea76c',
              Status: 'pending',
              AppliedAt: '2025-04-09T08:24:24.915',
              DeletedAt: null,
              ResumeUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744189601607-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
              CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
            },
            {
              ID: '4b709fba-ded6-4f9c-acd2-18d90b5c45c5',
              JobID: '580a1d7b-3474-4d6a-a90a-fa3dd8d519fb',
              Status: 'pending',
              AppliedAt: '2025-04-09T09:10:33.983',
              DeletedAt: null,
              ResumeUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744189827476-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
              CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
            },
          ],
        },
      },
    },
  })
  async getUsers(@Query() searchUsersDto: SearchUsersDto) {
    return this.usersService.handleGetUsers(searchUsersDto);
  }

  @Get(':id')
  @Roles(RoleEnum.ADMIN, RoleEnum.RECRUITER, RoleEnum.CANDIDATE)
  @ApiOperation({
    summary: 'Lấy thông tin chi tiết người dùng',
    description:
      'Đường dẫn này dùng để lấy ra thông tin chi tiết của người dùng.',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (Id) duy nhất của người dùng cần lấy thông tin.',
    example: '674c7204-106e-4d7f-8dc3-3f6389d0aa8e',
  })
  @ApiResponse({
    status: 200,
    examples: {
      example1: {
        summary: 'Thông tin của quản trị viên.',
        value: {
          ID: '30e4c46a-9817-486e-966a-f8457aaf5e41',
          Email: 'admin123@gmail.com',
          FullName: 'John Doe',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          PhoneNumber: '+840393874567',
          Status: 'active',
          CreatedAt: '2025-04-06T14:37:40.349',
          UpdatedAt: '2025-04-06T14:37:40.349',
          Role: 'admin',
          DeletedAt: null,
          IsEmailVerified: true,
        },
      },
      example2: {
        summary: 'Thông tin của nhà tuyển dụng',
        value: {
          ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          Position: 'Trưởng phòng nhân sự',
          FullName: 'Lê Văn Nam',
          Email: 'lengocanhpyne363@gmail.com',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          PhoneNumber: '+84393873632',
          IsEmailVerified: true,
          Company: {
            ID: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
            Name: 'Công ty ABC',
            LogoUrl: null,
            CreatedAt: '2025-04-06T15:51:31.73',
            UpdatedAt: '2025-04-06T15:51:31.73',
            WebsiteUrl: 'https://techcorp.com',
            Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
          },
          CompanyLocations: {
            ID: '3119455f-0091-47f9-8ec4-0f7db3ada5bb',
            Address:
              '1234 Khu phố 1, Đường Phạm Văn Đồng, Thành phố Hồ Chí Minh, Việt Nam.',
            CreatedAt: '2025-04-06T15:51:31.895',
            UpdatedAt: '2025-04-06T15:51:31.895',
            BranchName: 'Trụ sở chính',
          },
        },
      },
      example3: {
        summary: 'Thông tin của ứng viên',
        value: {
          ID: '891addf9-d54d-4c88-852d-fe96cb295536',
          ResumeUrl: null,
          Certifications: ['AWS Certified Developer', 'Google Cloud Associate'],
          Bio: 'Software developer with 3 years of experience in frontend development.',
          Level: 'senior',
          FullName: 'Lê Ngọc Anh',
          Email: 'lamduannhi0508@gmail.com',
          PhoneNumber: '+84393873631',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          Role: 'candidate',
          WorkExperiences: [
            {
              ID: 'fddf389e-a341-46bb-9c52-0a1f818c738f',
              EndDate: '2025-02-20T00:00:00',
              JobType: 'remote',
              Location: 'Phường 7, Quận Thủ Đức, TP. HCM',
              Position: 'Backend Developer',
              StartDate: '2024-11-01T08:00:00',
              CompanyName: 'Công ty KMS Technology',
              Descriptions: [
                'Viết API cho hệ thống backend',
                'Dùng framework NestJS để tăng khả năng mở rộng cho hệ thống',
              ],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744071950209-kms-tech.png',
            },
            {
              ID: 'f8df1734-259b-4cb1-b33f-dd0e299b7be3',
              EndDate: '2024-10-01T00:00:00',
              JobType: 'part_time',
              Location: 'Phường 7, Quận Thủ Đức, TP. HCM',
              Position: 'Frontend Developer',
              StartDate: '2024-05-01T08:00:00',
              CompanyName: 'Công ty KMS Technology',
              Descriptions: [
                'Thiết kế giao diện dùng Figma',
                'Dùng framework Next.js để viết giao diện',
              ],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744071580455-kms-tech.png',
            },
            {
              ID: '35910e7c-bcbf-4d0e-a260-cd4d59dd26f8',
              EndDate: null,
              JobType: 'part_time',
              Location: 'Quận Thủ Đức, TP. HCM',
              Position: 'Kỹ sư phần mềm',
              StartDate: '2024-05-01T08:00:00',
              CompanyName: 'Công ty phần mềm ABC',
              Descriptions: ['Viết NestJS', 'Dùng PostgreSQL'],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744070730106-logo-fpt-software_043151683.png',
            },
            {
              ID: '01c17e17-b4b2-4f5a-a12b-c843f257b586',
              EndDate: '2021-12-15T00:00:00',
              JobType: 'part_time',
              Location: 'Mountain View, California',
              Position: 'Lập trình viên Frontend',
              StartDate: '2020-06-01T00:00:00',
              CompanyName: 'Google',
              Descriptions: [
                'Xây dựng giao diện người dùng phản hồi bằng React',
                'Cải thiện hiệu năng lên 30%',
                'Hợp tác với các nhà thiết kế UX',
              ],
              CompanyLogoUrl: 'https://logo.clearbit.com/google.com',
            },
          ],
          Applications: [
            {
              ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
              JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
              Status: 'pending',
              AppliedAt: '2025-04-07T07:33:55.337',
              DeletedAt: null,
              ResumeUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
              CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
            },
          ],
        },
      },
    },
  })
  async getUser(
    @Param('id', ParseUUIDPipe) userId: string,
    @Req() request: Request,
  ) {
    const currentUserID = (request.user as User).id;

    return this.usersService.handleGetUser(userId, currentUserID);
  }

  @Patch(':id')
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  @ApiOperation({
    summary: 'Thay đổi thông tin người dùng',
    description: 'Đường dẫn này dùng để thay đổi thông tin người dùng',
  })
  @ApiExtraModels(UpdateCandidateDto, UpdateRecruiterDto)
  @ApiParam({
    name: 'id',
    description:
      'Mã định danh (ID) duy nhất của người dùng cần thay đổi thông tin.',
    example: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
  })
  @ApiBody({
    type: UpdateUserDto,
    examples: {
      candidate: {
        summary: 'Cập nhật ứng viên',
        value: {
          FullName: 'Nguyễn Văn A',
          PhoneNumber: '+84901234567',
          updateCandidateDto: {
            Certifications: ['IELTS 7.5', 'Google Developer Certificate'],
            Bio: 'Sinh viên năm cuối Đại học Bách Khoa',
            Level: 'junior',
          },
        },
      },
      recruiter: {
        summary: 'Cập nhật nhà tuyển dụng',
        value: {
          FullName: 'Trần Thị B',
          PhoneNumber: '+84909876543',
          updateRecruiterDto: {
            Position: 'Trưởng phòng nhân sự',
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    examples: {
      example1: {
        summary: 'Thông tin của quản trị viên.',
        value: {
          ID: '30e4c46a-9817-486e-966a-f8457aaf5e41',
          Email: 'admin123@gmail.com',
          FullName: 'John Doe',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          PhoneNumber: '+840393874567',
          Status: 'active',
          CreatedAt: '2025-04-06T14:37:40.349',
          UpdatedAt: '2025-04-06T14:37:40.349',
          Role: 'admin',
          DeletedAt: null,
          IsEmailVerified: true,
        },
      },
      example2: {
        summary: 'Thông tin của nhà tuyển dụng',
        value: {
          ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          Position: 'Trưởng phòng nhân sự',
          FullName: 'Lê Văn Nam',
          Email: 'lengocanhpyne363@gmail.com',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          PhoneNumber: '+84393873632',
          IsEmailVerified: true,
          Company: {
            ID: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
            Name: 'Công ty ABC',
            LogoUrl: null,
            CreatedAt: '2025-04-06T15:51:31.73',
            UpdatedAt: '2025-04-06T15:51:31.73',
            WebsiteUrl: 'https://techcorp.com',
            Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
          },
          CompanyLocations: {
            ID: '3119455f-0091-47f9-8ec4-0f7db3ada5bb',
            Address:
              '1234 Khu phố 1, Đường Phạm Văn Đồng, Thành phố Hồ Chí Minh, Việt Nam.',
            CreatedAt: '2025-04-06T15:51:31.895',
            UpdatedAt: '2025-04-06T15:51:31.895',
            BranchName: 'Trụ sở chính',
          },
        },
      },
      example3: {
        summary: 'Thông tin của ứng viên',
        value: {
          ID: '891addf9-d54d-4c88-852d-fe96cb295536',
          ResumeUrl: null,
          Certifications: ['AWS Certified Developer', 'Google Cloud Associate'],
          Bio: 'Software developer with 3 years of experience in frontend development.',
          Level: 'senior',
          FullName: 'Lê Ngọc Anh',
          Email: 'lamduannhi0508@gmail.com',
          PhoneNumber: '+84393873631',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          Role: 'candidate',
          WorkExperiences: [
            {
              ID: 'fddf389e-a341-46bb-9c52-0a1f818c738f',
              EndDate: '2025-02-20T00:00:00',
              JobType: 'remote',
              Location: 'Phường 7, Quận Thủ Đức, TP. HCM',
              Position: 'Backend Developer',
              StartDate: '2024-11-01T08:00:00',
              CompanyName: 'Công ty KMS Technology',
              Descriptions: [
                'Viết API cho hệ thống backend',
                'Dùng framework NestJS để tăng khả năng mở rộng cho hệ thống',
              ],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744071950209-kms-tech.png',
            },
            {
              ID: 'f8df1734-259b-4cb1-b33f-dd0e299b7be3',
              EndDate: '2024-10-01T00:00:00',
              JobType: 'part_time',
              Location: 'Phường 7, Quận Thủ Đức, TP. HCM',
              Position: 'Frontend Developer',
              StartDate: '2024-05-01T08:00:00',
              CompanyName: 'Công ty KMS Technology',
              Descriptions: [
                'Thiết kế giao diện dùng Figma',
                'Dùng framework Next.js để viết giao diện',
              ],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744071580455-kms-tech.png',
            },
            {
              ID: '35910e7c-bcbf-4d0e-a260-cd4d59dd26f8',
              EndDate: null,
              JobType: 'part_time',
              Location: 'Quận Thủ Đức, TP. HCM',
              Position: 'Kỹ sư phần mềm',
              StartDate: '2024-05-01T08:00:00',
              CompanyName: 'Công ty phần mềm ABC',
              Descriptions: ['Viết NestJS', 'Dùng PostgreSQL'],
              CompanyLogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744070730106-logo-fpt-software_043151683.png',
            },
            {
              ID: '01c17e17-b4b2-4f5a-a12b-c843f257b586',
              EndDate: '2021-12-15T00:00:00',
              JobType: 'part_time',
              Location: 'Mountain View, California',
              Position: 'Lập trình viên Frontend',
              StartDate: '2020-06-01T00:00:00',
              CompanyName: 'Google',
              Descriptions: [
                'Xây dựng giao diện người dùng phản hồi bằng React',
                'Cải thiện hiệu năng lên 30%',
                'Hợp tác với các nhà thiết kế UX',
              ],
              CompanyLogoUrl: 'https://logo.clearbit.com/google.com',
            },
          ],
          Applications: [
            {
              ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
              JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
              Status: 'pending',
              AppliedAt: '2025-04-07T07:33:55.337',
              DeletedAt: null,
              ResumeUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
              CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
            },
          ],
        },
      },
    },
  })
  @UseInterceptors(AnyFilesInterceptor())
  async updateUser(
    @Param('id', ParseUUIDPipe) userId: string,
    @Req() request: Request,
    @Body() updateUserDto: UpdateUserDto,
    @FileValidationDecorator() files: Express.Multer.File[],
  ) {
    const currentUserId = (request.user as User).id;

    return this.usersService.handleUpdateUser(
      userId,
      updateUserDto,
      currentUserId,
      files,
    );
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Khoá (Xoá) tài khoản người dùng',
    description:
      'Đường dẫn này dùg để khoá (xoá) tài khoản người dùng. Chỉ có quản trị viên mới có quyền truy cập.',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (Id) duy nhất của người dùng.',
    example: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: '674c7204-106e-4d7f-8dc3-3f6389d0aa8e',
          Email: 'lengocanhpyne363@gmail.com',
          FullName: 'Lê Văn Nam',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          PhoneNumber: '+84393873632',
          Status: 'active',
          CreatedAt: '2025-04-06T15:51:31.508',
          UpdatedAt: '2025-04-06T15:51:31.508',
          Role: 'recruiter',
          DeletedAt: null,
          IsEmailVerified: true,
        },
        {
          ID: 'ee40a614-0e80-48bf-b69d-7987d6bedc4c',
          Email: 'lamduannhi0508@gmail.com',
          FullName: 'Lê Ngọc Anh',
          AvatarUrl:
            'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
          PhoneNumber: '+84393873631',
          Status: 'active',
          CreatedAt: '2025-04-06T15:49:08.349',
          UpdatedAt: '2025-04-06T15:49:08.349',
          Role: 'candidate',
          DeletedAt: null,
          IsEmailVerified: true,
        },
      ],
    },
  })
  @Roles(RoleEnum.ADMIN)
  async deleteUser(
    @Param('id', ParseUUIDPipe) roleId: string,
    @Query() deleteUserQueryDto: DeleteUserQueryDto,
  ) {
    return this.usersService.handleDeleteUser(roleId, deleteUserQueryDto);
  }

  @Get(':id/notifications')
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  @ApiOperation({
    summary: 'Lấy danh sách các thông báo của người dùng.',
    description:
      'Đường dẫn này dùng để lấy ra danh sách các thông báo của người dùng.',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) duy nhất của người dùng.',
    example: '674c7204-106e-4d7f-8dc3-3f6389d0aa8e',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: 'f7f12038-d244-414d-b367-6594f19aa82b',
          IsRead: false,
          Content: [
            'Bài đăng mới: Frontend Developer (Junior)',
            'Tạo bởi: Công ty ABC',
            'Vào lúc: 09/04/2025 08:56:24 AM',
          ],
          Metadata: {
            jobId: '12bfb97c-a3d1-404c-8002-045e5417ef39',
            jobTitle: 'Frontend Developer (Junior)',
            companyName: 'Công ty ABC',
            recruiterId: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          },
          CreatedAt: '2025-04-09T00:51:06.838',
        },
        {
          ID: '97c2d084-9495-4fd8-9c4e-f5fd13351f43',
          IsRead: false,
          Content: [
            'Bài đăng mới: AI Engineer (Junior)',
            'Tạo bởi: Công ty ABC',
            'Vào lúc: 09/04/2025 08:56:24 AM',
          ],
          Metadata: {
            jobId: 'aeb5e508-9c97-4cdd-98b5-8ec8d2b62e13',
            jobTitle: 'AI Engineer (Junior)',
            companyName: 'Công ty ABC',
            recruiterId: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          },
          CreatedAt: '2025-04-09T00:56:45.876',
        },
      ],
    },
  })
  async getNotifications(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ) {
    const userId = (request.user as User).id;

    return this.usersService.handleGetNotificationsOfUser(id, userId);
  }

  @Get(':id/notifications/:notificationId')
  @ApiOperation({
    summary: 'Lấy ra chi tiết một thông báo của người dùng',
    description:
      'Đường dẫn này dùng để lấy ra chi tiết một thông báo của người dùng.',
  })
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  @ApiResponse({
    status: 200,
    schema: {
      example: {
        ID: 'f7f12038-d244-414d-b367-6594f19aa82b',
        IsRead: false,
        Content: [
          'Bài tuyển dụng mới: Frontend Developer (Junior)',
          'Tạo bởi: Công ty ABC',
          'Vào lúc: 09/04/2025 08:56:24 AM',
        ],
        Metadata: {
          jobId: '12bfb97c-a3d1-404c-8002-045e5417ef39',
          jobTitle: 'Frontend Developer (Junior)',
          companyName: 'Công ty ABC',
          recruiterId: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
        },
        CreatedAt: '2025-04-09T00:51:06.838',
      },
    },
  })
  @ApiParam({
    name: 'id',
    description:
      'Mã định danh (ID) duy nhất của người dùng cần lấy thông báo chi tiết.',
    example: '30e4c46a-9817-486e-966a-f8457aaf5e41',
  })
  @ApiParam({
    name: 'notificationId',
    description: 'Mã định danh (ID) duy nhất của thông báo cần xem chi tiết.',
    example: '3d1a55ec-29fe-4cc2-9379-b1b6dd46d0ed',
  })
  async getNotificationDetails(
    @Param('id', ParseUUIDPipe) id: string,
    @Param('notificationId', ParseUUIDPipe) notificationId: string,
    @Req() request: Request,
  ) {
    const currentUserId = (request.user as User).id;

    return this.usersService.handleGetNotificationDetails(
      id,
      notificationId,
      currentUserId,
    );
  }

  @Delete(':id/notifications/:notificationId')
  @ApiOperation({
    summary: 'Xoá thông báo của người dùng',
    description: 'Đường dẫn này dùng để xoá thông báo của người dùng.',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: 'f7f12038-d244-414d-b367-6594f19aa82b',
          IsRead: false,
          Content: [
            'Bài đăng mới: Frontend Developer (Junior)',
            'Tạo bởi: Công ty ABC',
            'Vào lúc: 09/04/2025 08:56:24 AM',
          ],
          Metadata: {
            jobId: '12bfb97c-a3d1-404c-8002-045e5417ef39',
            jobTitle: 'Frontend Developer (Junior)',
            companyName: 'Công ty ABC',
            recruiterId: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          },
          CreatedAt: '2025-04-09T00:51:06.838',
        },
        {
          ID: '97c2d084-9495-4fd8-9c4e-f5fd13351f43',
          IsRead: false,
          Content: [
            'Bài đăng mới: AI Engineer (Junior)',
            'Tạo bởi: Công ty ABC',
            'Vào lúc: 09/04/2025 08:56:24 AM',
          ],
          Metadata: {
            jobId: 'aeb5e508-9c97-4cdd-98b5-8ec8d2b62e13',
            jobTitle: 'AI Engineer (Junior)',
            companyName: 'Công ty ABC',
            recruiterId: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          },
          CreatedAt: '2025-04-09T00:56:45.876',
        },
      ],
    },
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) duy nhất của người dùng cần xoá thông báo.',
    example: '30e4c46a-9817-486e-966a-f8457aaf5e41',
  })
  @ApiParam({
    name: 'notificationId',
    description: 'Mã định danh (ID) duy nhất của thông báo cần xoá.',
    example: '3d1a55ec-29fe-4cc2-9379-b1b6dd46d0ed',
  })
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  async deleteNotification(
    @Req() request: Request,
    @Param('id', ParseUUIDPipe) userId: string,
    @Param('notificationId', ParseUUIDPipe) notificationId: string,
  ) {
    const currentUserId = (request.user as User).id;

    return this.usersService.handleDeleteNotification(
      userId,
      notificationId,
      currentUserId,
    );
  }
}
