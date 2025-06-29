import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard, SupabaseGuard } from 'src/libs/common/guards';
import { API_TAGS, RoleEnum } from 'src/libs/common/utils';
import {
  CreateJobDto,
  CreateJobFavoritesDto,
  DeleteJobFavoritesDto,
  ProcessJobStatusDto,
  SearchJobQueryDto,
  UpdateJobDto,
} from 'src/modules/jobs/dtos';
import { JobsService } from './jobs.service';

@Controller('jobs')
@UseGuards(SupabaseGuard, RoleAuthGuard)
@ApiBearerAuth()
@ApiTags(API_TAGS.JOB)
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @Get()
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  @ApiOperation({
    summary: 'Danh sách các công việc hiện có trong hệ thống.',
    description:
      'Đường dẫn này dùng để lấy ra danh sách các công việc hiện có trong hệ thống.',
  })
  @ApiResponse({
    status: 200,
    description: 'Dữ liệu trả về sau khi lấy danh sách công việc thành công.',
    schema: {
      example: [
        {
          ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
          Title: 'Thực tập sinh Web Developer',
          Description:
            'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
          Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
          Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
          Vacancies: 3,
          Type: 'part_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          Status: 'open',
          PostedAt: '2025-04-07T07:27:06.061',
          ExpiredAt: '2025-06-15T23:59:59',
          Level: 'intern',
          DeletedAt: null,
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            AvatarUrl:
              'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1747550944599-1747494653748-1747154111462-1747150754868-1747070271297-1000003940.jpg',
            DeletedAt: null,
            FullName: 'Lê Văn Nam',
            Company: {
              ID: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
              Name: 'Công ty ABC',
              LogoUrl: null,
              CreatedAt: '2025-04-06T15:51:31.73',
              UpdatedAt: '2025-04-06T15:51:31.73',
              WebsiteUrl: 'https://techcorp.com',
              Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
            },
          },
          Categories: ['Back End'],
        },
      ],
    },
  })
  async getJobs(
    @Req() request: Request,
    @Query() searchJobQueryDto?: SearchJobQueryDto,
  ) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetJobs(userId, searchJobQueryDto);
  }

  @Get('candidates/:candidateId/recommended-jobs')
  @ApiOperation({
    summary: 'Lấy danh sách các công việc gợi ý cho ứng viên',
    description:
      'Đường dẫn này dùng để lấy danh sách các công việc gợi ý cho ứng viên. Chỉ có ứng viên mới có quyền truy cập.',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
          Title: 'Thực tập sinh Web Developer',
          Description:
            'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
          Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
          Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
          Vacancies: 2,
          Type: 'part_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          Status: 'open',
          PostedAt: '2025-04-07T07:27:06.061Z',
          ExpiredAt: '2025-06-15T23:59:59.000Z',
          Level: 'senior',
          DeletedAt: null,
          JobBenefits: [
            'Có mentor hướng dẫn trong suốt thời gian thực tập.',
            'Hỗ trợ chi phí, có cơ hội trở thành nhân viên chính thức.',
            'Môi trường làm việc thân thiện, linh hoạt giờ giấc.',
          ],
          JobDescriptions: [
            'Có kiến thức cơ bản về Docker, CI/CD',
            'Có ít nhất 1 năm kinh nghiệm với Spring Boot (Java)',
            'Sử dụng thành thạo framework Next.js',
          ],
          JobRequirements: [
            'Sinh viên năm 3 trở lên chuyên ngành CNTT hoặc liên quan.',
            'Biết cơ bản HTML, CSS, JavaScript.',
            'Biết React là một lợi thế.',
            'Chăm chỉ, ham học hỏi, có tinh thần trách nhiệm.',
          ],
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            FullName: 'Lê Văn Nam',
            Email: 'lengocanhpyne363@gmail.com',
            PhoneNumber: '+84393873632',
            AvatarUrl:
              'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
            Company: {
              Name: 'Công ty phần mềm FPT Software',
              LogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//logo-fpt-software_043151683.png',
            },
          },
          Categories: ['Front End'],
        },
        {
          ID: 'e9a4b957-3e7e-48c8-b88e-fd26d83ea76c',
          Title: 'QA Tester (Junior)',
          Description:
            'Chúng tôi đang tìm kiếm một QA Tester (Junior) có khả năng kiểm thử thủ công và hỗ trợ kiểm thử tự động cho các ứng dụng web của công ty.',
          Address: 'Quận Tân Bình, TP. Hồ Chí Minh, Việt Nam',
          Salary: '9,000,000 - 13,000,000 VND/tháng',
          Vacancies: 1,
          Type: 'full_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          Status: 'open',
          PostedAt: '2025-04-09T03:44:17.222Z',
          ExpiredAt: '2025-07-31T23:59:59.000Z',
          Level: 'junior',
          DeletedAt: null,
          JobBenefits: [
            'Lương tháng 13, xét tăng lương định kỳ.',
            'Cơ hội học hỏi về kiểm thử tự động (Automation Testing).',
            'Tham gia vào các dự án thực tế từ sớm.',
            'Được đào tạo về quy trình kiểm thử chuyên nghiệp.',
          ],
          JobDescriptions: [
            'Phối hợp với developer để phát hiện và tái hiện lỗi.',
            'Ghi nhận lỗi và theo dõi tiến độ xử lý qua hệ thống quản lý lỗi (Jira, Trello).',
            'Viết và thực thi test case, test plan theo yêu cầu dự án.',
            'Thực hiện kiểm thử chức năng (manual testing) cho các sản phẩm web.',
          ],
          JobRequirements: [
            'Cẩn thận, kiên nhẫn và có tư duy logic tốt.',
            'Biết sử dụng một số công cụ như Postman, Chrome DevTools là lợi thế.',
            'Tốt nghiệp ngành Công nghệ Thông tin hoặc tương đương.',
            'Hiểu biết cơ bản về kiểm thử phần mềm và vòng đời phát triển phần mềm (SDLC).',
            'Có tinh thần học hỏi, teamwork tốt, chịu được áp lực công việc.',
          ],
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            FullName: 'Lê Văn Nam',
            Email: 'lengocanhpyne363@gmail.com',
            PhoneNumber: '+84393873632',
            AvatarUrl:
              'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
            Company: {
              Name: 'Công ty phần mềm FPT Software',
              LogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//logo-fpt-software_043151683.png',
            },
          },
          Categories: ['Front End'],
        },
        {
          ID: '55f8a244-3056-424c-98cc-9c15a89c0234',
          Title: 'UI/UX Designer (Junior)',
          Description:
            'Chúng tôi đang tìm kiếm UI/UX Designer có tư duy thiết kế tốt, đam mê sáng tạo để thiết kế giao diện thân thiện với người dùng cho các ứng dụng web và mobile.',
          Address: 'Quận 10, TP. Hồ Chí Minh, Việt Nam',
          Salary: '10,000,000 - 14,000,000 VND/tháng',
          Vacancies: 1,
          Type: 'full_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 9:00 - 18:00',
          Status: 'open',
          PostedAt: '2025-04-09T03:43:43.791Z',
          ExpiredAt: '2025-07-20T23:59:59.000Z',
          Level: 'junior',
          DeletedAt: null,
          JobBenefits: [
            'Hỗ trợ công cụ thiết kế (Figma Premium, Adobe Suite, v.v.).',
            'Môi trường năng động, khuyến khích sáng tạo và đưa ra ý tưởng.',
            'Được đào tạo thêm về UI/UX trends và usability testing.',
            'Cơ hội làm việc với nhiều dự án thực tế, đa ngành.',
          ],
          JobDescriptions: [
            'Thiết kế wireframe, prototype và giao diện người dùng cho website/mobile app.',
            'Phối hợp với team phát triển để đảm bảo thiết kế được hiện thực hóa chính xác.',
            'Cải tiến trải nghiệm người dùng dựa trên phản hồi và dữ liệu hành vi.',
            'Đảm bảo tính nhất quán của hệ thống thiết kế (design system).',
          ],
          JobRequirements: [
            'Tối thiểu 6 tháng kinh nghiệm thiết kế UI/UX.',
            'Hiểu về nguyên lý thiết kế, hành vi người dùng và mobile-first design.',
            'Có portfolio cá nhân là một lợi thế lớn.',
            'Kỹ năng giao tiếp, lắng nghe và làm việc nhóm tốt.',
            'Sử dụng thành thạo Figma hoặc Adobe XD.',
          ],
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            FullName: 'Lê Văn Nam',
            Email: 'lengocanhpyne363@gmail.com',
            PhoneNumber: '+84393873632',
            AvatarUrl:
              'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
            Company: {
              Name: 'Công ty phần mềm FPT Software',
              LogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//logo-fpt-software_043151683.png',
            },
          },
          Categories: ['Front End'],
        },
        {
          ID: '12bfb97c-a3d1-404c-8002-045e5417ef39',
          Title: 'Frontend Developer (Junior)',
          Description:
            'Chúng tôi đang tìm kiếm Frontend Developer có kinh nghiệm cơ bản với React để cùng phát triển giao diện người dùng cho các sản phẩm web hiện đại.',
          Address: 'Quận 1, TP. Hồ Chí Minh, Việt Nam',
          Salary: '10 triệu - 15 triệu VNĐ/tháng',
          Vacancies: 1,
          Type: 'full_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 9:00 - 18:00',
          Status: 'open',
          PostedAt: '2025-04-09T00:51:05.681Z',
          ExpiredAt: '2025-06-30T23:59:59.000Z',
          Level: 'junior',
          DeletedAt: null,
          JobBenefits: [
            'Môi trường startup trẻ, năng động và sáng tạo.',
            'Xét tăng lương định kỳ, cơ hội học hỏi từ senior team.',
            'Hỗ trợ chi phí gửi xe, cơm trưa.',
            'Tham gia các workshop nội bộ và sự kiện công ty.',
          ],
          JobDescriptions: [
            'Tham gia phân tích, cải tiến UI/UX dựa trên phản hồi của người dùng.',
            'Phối hợp với Backend team để tích hợp API vào giao diện.',
            'Đảm bảo hiệu suất, khả năng phản hồi và khả năng tương thích trình duyệt.',
            'Phát triển và tối ưu giao diện người dùng sử dụng React, Next.js.',
          ],
          JobRequirements: [
            'Biết sử dụng Git, có kinh nghiệm làm việc với RESTful API.',
            'Tinh thần học hỏi, teamwork tốt, cầu tiến.',
            'Tối thiểu 6 tháng kinh nghiệm làm việc với React hoặc Next.js.',
            'Nắm vững HTML, CSS, JavaScript ES6+.',
            'Hiểu về responsive design, cross-browser compatibility.',
          ],
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            FullName: 'Lê Văn Nam',
            Email: 'lengocanhpyne363@gmail.com',
            PhoneNumber: '+84393873632',
            AvatarUrl:
              'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
            Company: {
              Name: 'Công ty phần mềm FPT Software',
              LogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//logo-fpt-software_043151683.png',
            },
          },
          Categories: ['Front End'],
        },
        {
          ID: '15e09a20-11da-416f-a6b7-5789f55c8522',
          Title: 'Thực tập sinh Backend Developer',
          Description:
            'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình backend để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
          Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
          Salary: 'Hỗ trợ 4,000,000 - 6,000,000 VND/tháng',
          Vacancies: 2,
          Type: 'full_time',
          WorkingTimes: 'Thứ 3 - Thứ 6, 8:30 - 17:30',
          Status: 'open',
          PostedAt: '2025-04-08T16:48:14.565Z',
          ExpiredAt: '2025-04-28T23:59:59.000Z',
          Level: 'intern',
          DeletedAt: null,
          JobBenefits: [
            'Hỗ trợ chi phí, có cơ hội trở thành nhân viên chính thức.',
            'Môi trường làm việc thân thiện, linh hoạt giờ giấc.',
            'Có mentor hướng dẫn trong suốt thời gian thực tập.',
          ],
          JobDescriptions: [
            'Hỗ trợ kiểm thử và xử lý lỗi trên hệ thống.',
            'Tham gia phát triển giao diện người dùng bằng HTML, CSS, JavaScript.',
            'Học hỏi và áp dụng React vào các dự án nội bộ.',
          ],
          JobRequirements: [
            'Sinh viên năm 3 trở lên chuyên ngành CNTT hoặc liên quan.',
            'Biết React là một lợi thế.',
            'Biết cơ bản HTML, CSS, JavaScript.',
            'Chăm chỉ, ham học hỏi, có tinh thần trách nhiệm.',
          ],
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            FullName: 'Lê Văn Nam',
            Email: 'lengocanhpyne363@gmail.com',
            PhoneNumber: '+84393873632',
            AvatarUrl:
              'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
            Company: {
              Name: 'Công ty phần mềm FPT Software',
              LogoUrl:
                'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//logo-fpt-software_043151683.png',
            },
          },
          Categories: ['Front End'],
        },
      ],
    },
  })
  @ApiParam({
    name: 'candidateId',
    description: 'Mã định danh (ID) của ứng viên',
    example: '891addf9-d54d-4c88-852d-fe96cb295536',
  })
  @Roles(RoleEnum.CANDIDATE)
  async getRecommendJobsForCandidate(
    @Req() request: Request,
    @Param('candidateId', ParseUUIDPipe) candidateId: string,
  ) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetRecommendedJobsForCandidate(
      candidateId,
      userId,
    );
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Lấy thông tin chi tiết của công việc',
    description: 'Đường dẫn này dùng để lấy thông tin chi tiết của công việc.',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) của công việc',
    example: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: {
        ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
        Title: 'Thực tập sinh Web Developer',
        Description:
          'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
        Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
        Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
        Vacancies: 3,
        Type: 'part_time',
        WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
        Status: 'open',
        PostedAt: '2025-04-07T07:27:06.061',
        ExpiredAt: '2025-06-15T23:59:59',
        Level: 'senior',
        JobDescriptions: [
          'Có ít nhất 1 năm kinh nghiệm với Spring Boot (Java)',
          'Sử dụng thành thạo framework Next.js',
          'Có kiến thức cơ bản về Docker, CI/CD',
        ],
        JobBenefits: [
          'Có mentor hướng dẫn trong suốt thời gian thực tập.',
          'Hỗ trợ chi phí, có cơ hội trở thành nhân viên chính thức.',
          'Môi trường làm việc thân thiện, linh hoạt giờ giấc.',
        ],
        JobRequirements: [
          'Sinh viên năm 3 trở lên chuyên ngành CNTT hoặc liên quan.',
          'Biết cơ bản HTML, CSS, JavaScript.',
          'Biết React là một lợi thế.',
          'Chăm chỉ, ham học hỏi, có tinh thần trách nhiệm.',
        ],
        Categories: ['Front End', 'Back End'],
        Recruiter: {
          ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          Position: 'Trưởng phòng nhân sự',
          DeletedAt: null,
          FullName: 'Lê Văn Nam',
          Company: {
            ID: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
            Name: 'Công ty ABC',
            LogoUrl: null,
            CreatedAt: '2025-04-06T15:51:31.73',
            UpdatedAt: '2025-04-06T15:51:31.73',
            WebsiteUrl: 'https://techcorp.com',
            Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
          },
        },
      },
    },
  })
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  async getJob(
    @Req() request: Request,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetJob(id, userId);
  }

  @Post()
  @Roles(RoleEnum.RECRUITER)
  @ApiOperation({
    summary: 'Tạo mới công việc',
    description:
      'Đường dẫn này dùng để tạo mới công việc. Chỉ có nhà tuyển dụng mới có quyền truy cập.',
  })
  @ApiResponse({
    status: 200,
    description: 'Dữ liệu trả về sau khi tạo mới công việc thành công.',
    schema: {
      example: [
        {
          ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
          Title: 'Thực tập sinh Web Developer',
          Description:
            'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
          Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
          Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
          Vacancies: 3,
          Type: 'part_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          Status: 'open',
          PostedAt: '2025-04-07T07:27:06.061',
          ExpiredAt: '2025-06-15T23:59:59',
          Level: 'intern',
          DeletedAt: null,
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            DeletedAt: null,
            FullName: 'Lê Văn Nam',
            Company: {
              ID: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
              Name: 'Công ty ABC',
              LogoUrl: null,
              CreatedAt: '2025-04-06T15:51:31.73',
              UpdatedAt: '2025-04-06T15:51:31.73',
              WebsiteUrl: 'https://techcorp.com',
              Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
            },
          },
          Categories: ['Back End'],
        },
      ],
    },
  })
  @ApiBody({
    type: CreateJobDto,
    description: 'Dữ liệu cần gửi đi để tạo mới công việc.',
  })
  async createJob(@Body() createJobDto: CreateJobDto, @Req() request: Request) {
    return this.jobsService.handleCreateJob(
      createJobDto,
      (request.user as User).id,
    );
  }

  @Patch(':id')
  @ApiOperation({
    summary: 'Cập nhật thông tin công việc',
    description:
      'Đường dẫn này dùng để cập nhật thông tin công việc nếu như công việc vẫn còn chờ quản trị viên duyệt.',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) duy nhất của công việc cần chỉnh sửa.',
    example: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: {
        ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
        Title: 'Thực tập sinh Web Developer',
        Description:
          'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
        Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
        Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
        Vacancies: 3,
        Type: 'part_time',
        WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
        Status: 'open',
        PostedAt: '2025-04-07T07:27:06.061',
        ExpiredAt: '2025-06-15T23:59:59',
        Level: 'intern',
        DeletedAt: null,
        Recruiter: {
          ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          Position: 'Trưởng phòng nhân sự',
          FullName: 'Lê Văn Nam',
          PhoneNumber: '+84393873632',
          Email: 'lengocanhpyne363@gmail.com',
          Company: {
            Name: 'Công ty phần mềm FPT Software',
            LogoUrl:
              'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//logo-fpt-software_043151683.png',
          },
        },
        JobDescriptions: [
          'Có ít nhất 1 năm kinh nghiệm với Spring Boot (Java)',
          'Sử dụng thành thạo framework Next.js',
          'Có kiến thức cơ bản về Docker, CI/CD',
        ],
        JobBenefits: [
          'Có mentor hướng dẫn trong suốt thời gian thực tập.',
          'Hỗ trợ chi phí, có cơ hội trở thành nhân viên chính thức.',
          'Môi trường làm việc thân thiện, linh hoạt giờ giấc.',
        ],
        JobRequirements: [
          'Sinh viên năm 3 trở lên chuyên ngành CNTT hoặc liên quan.',
          'Biết cơ bản HTML, CSS, JavaScript.',
          'Biết React là một lợi thế.',
          'Chăm chỉ, ham học hỏi, có tinh thần trách nhiệm.',
        ],
        Categories: ['Front End', 'Back End'],
      },
    },
  })
  @ApiBody({
    type: UpdateJobDto,
    description: 'Dữ liệu cần gửi đi để cập nhật công việc.',
  })
  @Roles(RoleEnum.RECRUITER)
  async updateJob(
    @Param('id', ParseUUIDPipe) jobId: string,
    @Body() updateJobDto: UpdateJobDto,
  ) {
    return this.jobsService.handleUpdateJob(jobId, updateJobDto);
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Xoá mềm công việc',
    description: 'Đường dẫn này dùng để xoá mềm công việc.',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) của công việc cần xoá',
    example: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
          Title: 'Thực tập sinh Web Developer',
          Description:
            'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
          Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
          Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
          Vacancies: 3,
          Type: 'part_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          Status: 'open',
          PostedAt: '2025-04-07T07:27:06.061',
          ExpiredAt: '2025-06-15T23:59:59',
          Level: 'intern',
          DeletedAt: null,
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            DeletedAt: null,
            FullName: 'Lê Văn Nam',
            Company: {
              ID: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
              Name: 'Công ty ABC',
              LogoUrl: null,
              CreatedAt: '2025-04-06T15:51:31.73',
              UpdatedAt: '2025-04-06T15:51:31.73',
              WebsiteUrl: 'https://techcorp.com',
              Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
            },
          },
          Categories: ['Back End'],
        },
      ],
    },
  })
  @Roles(RoleEnum.ADMIN, RoleEnum.RECRUITER)
  async deleteJob(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ) {
    return this.jobsService.handleDeleteJob(id, (request.user as User).id);
  }

  @Patch('process/status')
  @Roles(RoleEnum.ADMIN)
  @ApiOperation({
    summary: 'Xử lý các công việc đăng tuyển của nhà tuyển dụng',
    description:
      'Đường dẫn này dùng để xử lý công việc đăng tuyển (chấp thuận, từ chối) của nhà tuyển dụng bởi quản trị viên. Chỉ có quản trị viên mới có quyền truy cập.',
  })
  @ApiResponse({
    status: 200,
    description: 'Trả về dữ liệu bao gồm những công việc có trạng thái là mở.',
    schema: {
      example: [
        {
          ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
          Title: 'Thực tập sinh Web Developer',
          Description:
            'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
          Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
          Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
          Vacancies: 3,
          Type: 'part_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          Status: 'open',
          PostedAt: '2025-04-07T07:27:06.061',
          ExpiredAt: '2025-06-15T23:59:59',
          Level: 'intern',
          DeletedAt: null,
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            DeletedAt: null,
            FullName: 'Lê Văn Nam',
            Company: {
              ID: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
              Name: 'Công ty ABC',
              LogoUrl: null,
              CreatedAt: '2025-04-06T15:51:31.73',
              UpdatedAt: '2025-04-06T15:51:31.73',
              WebsiteUrl: 'https://techcorp.com',
              Description: 'Công ty đứng đầu về công nghệ tại Việt Nam',
            },
          },
          Categories: ['Back End'],
        },
      ],
    },
  })
  @ApiBody({
    type: ProcessJobStatusDto,
    description: 'Dữ liệu cần gửi đi để xử lý đơn ứng tuyển.',
    examples: {
      example1: {
        summary: 'Trường hợp chỉ gửi đi những công việc mà đồng ý đăng tuyển.',
        value: {
          openJobIds: ['e9a4b957-3e7e-48c8-b88e-fd26d83ea76c'],
        },
      },
      example2: {
        summary: 'Trường hợp chỉ gửi đi những công việc mà từ chối đăng tuyển.',
        value: {
          rejectedJobs: [
            {
              jobId: '8d3d5fac-fab6-460d-868c-32f73624e9bc',
              reason:
                'Bài đăng tuyển của bạn đã vi phạm các chính sách bảo mật của hệ thống.',
            },
          ],
        },
      },
      example3: {
        summary:
          'Trường hợp gửi đi cả những công việc đồng ý và từ chối đăng tuyển.',
        value: {
          rejectedJobs: [
            {
              jobId: '8d3d5fac-fab6-460d-868c-32f73624e9bc',
              reason:
                'Bài đăng tuyển của bạn đã vi phạm các chính sách bảo mật của hệ thống.',
            },
          ],
          openJobIds: [
            '15e09a20-11da-416f-a6b7-5789f55c8522',
            '12bfb97c-a3d1-404c-8002-045e5417ef39',
          ],
        },
      },
    },
  })
  async processStatusOfJobs(
    @Body() processJobStatusDto: ProcessJobStatusDto,
    @Req() request: Request,
  ) {
    const userId = (request.user as User).id;

    return this.jobsService.handleProcessStatusOfJob(
      processJobStatusDto,
      userId,
    );
  }

  @Get('candidates/favorites')
  @Roles(RoleEnum.CANDIDATE)
  @ApiOperation({
    summary: 'Lấy danh sách các công việc ưa thích của ứng viên',
    description:
      'Đường dẫn này dùng để lấy ra danh sách các công việc ưa thích của ứng viên.',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: '1d63eabe-b07f-4a1b-8a8d-0b710b90b5f4',
          SavedAt: '2025-04-29T12:36:18.563',
          DeletedAt: null,
          Job: {
            ID: '55f8a244-3056-424c-98cc-9c15a89c0234',
            Type: 'full_time',
            Level: 'junior',
            Title: 'UI/UX Designer (Junior)',
            Salary: '10,000,000 - 14,000,000 VND/tháng',
            Status: 'open',
            Address: 'Quận 10, TP. Hồ Chí Minh, Việt Nam',
            PostedAt: '2025-04-09T03:43:43.791',
            DeletedAt: null,
            ExpiredAt: '2025-07-20T23:59:59',
            Vacancies: 1,
            Description:
              'Chúng tôi đang tìm kiếm UI/UX Designer có tư duy thiết kế tốt, đam mê sáng tạo để thiết kế giao diện thân thiện với người dùng cho các ứng dụng web và mobile.',
            JobBenefits: [
              'Cơ hội làm việc với nhiều dự án thực tế, đa ngành.',
              'Hỗ trợ công cụ thiết kế (Figma Premium, Adobe Suite, v.v.).',
              'Môi trường năng động, khuyến khích sáng tạo và đưa ra ý tưởng.',
              'Được đào tạo thêm về UI/UX trends và usability testing.',
            ],
            WorkingTimes: 'Thứ 2 - Thứ 6, 9:00 - 18:00',
            JobDescriptions: [
              'Thiết kế wireframe, prototype và giao diện người dùng cho website/mobile app.',
              'Phối hợp với team phát triển để đảm bảo thiết kế được hiện thực hóa chính xác.',
              'Cải tiến trải nghiệm người dùng dựa trên phản hồi và dữ liệu hành vi.',
              'Đảm bảo tính nhất quán của hệ thống thiết kế (design system).',
            ],
            JobRequirements: [
              'Tối thiểu 6 tháng kinh nghiệm thiết kế UI/UX.',
              'Sử dụng thành thạo Figma hoặc Adobe XD.',
              'Hiểu về nguyên lý thiết kế, hành vi người dùng và mobile-first design.',
              'Có portfolio cá nhân là một lợi thế lớn.',
              'Kỹ năng giao tiếp, lắng nghe và làm việc nhóm tốt.',
            ],
            Categories: ['UI/UX Designer'],
            Recruiter: {
              ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
              FullName: 'Lê Văn Nam',
              Position: 'Trưởng phòng nhân sự',
              Email: 'lengocanhpyne363@gmail.com',
              PhoneNumber: '+84393873632',
              AvatarUrl:
                'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
              Company: {
                Name: 'Công ty phần mềm FPT Software',
                LogoUrl:
                  'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//logo-fpt-software_043151683.png',
              },
            },
          },
        },
        {
          ID: 'c09bd1a2-ccef-4c72-8355-c8a0a4b4935f',
          SavedAt: '2025-04-29T12:36:38.655',
          DeletedAt: null,
          Job: {
            ID: 'e9a4b957-3e7e-48c8-b88e-fd26d83ea76c',
            Type: 'full_time',
            Level: 'junior',
            Title: 'QA Tester (Junior)',
            Salary: '9,000,000 - 13,000,000 VND/tháng',
            Status: 'open',
            Address: 'Quận Tân Bình, TP. Hồ Chí Minh, Việt Nam',
            PostedAt: '2025-04-09T03:44:17.222',
            DeletedAt: null,
            ExpiredAt: '2025-07-31T23:59:59',
            Vacancies: 1,
            Description:
              'Chúng tôi đang tìm kiếm một QA Tester (Junior) có khả năng kiểm thử thủ công và hỗ trợ kiểm thử tự động cho các ứng dụng web của công ty.',
            JobBenefits: [
              'Được đào tạo về quy trình kiểm thử chuyên nghiệp.',
              'Cơ hội học hỏi về kiểm thử tự động (Automation Testing).',
              'Tham gia vào các dự án thực tế từ sớm.',
              'Lương tháng 13, xét tăng lương định kỳ.',
            ],
            WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
            JobDescriptions: [
              'Thực hiện kiểm thử chức năng (manual testing) cho các sản phẩm web.',
              'Viết và thực thi test case, test plan theo yêu cầu dự án.',
              'Phối hợp với developer để phát hiện và tái hiện lỗi.',
              'Ghi nhận lỗi và theo dõi tiến độ xử lý qua hệ thống quản lý lỗi (Jira, Trello).',
            ],
            JobRequirements: [
              'Tốt nghiệp ngành Công nghệ Thông tin hoặc tương đương.',
              'Hiểu biết cơ bản về kiểm thử phần mềm và vòng đời phát triển phần mềm (SDLC).',
              'Cẩn thận, kiên nhẫn và có tư duy logic tốt.',
              'Biết sử dụng một số công cụ như Postman, Chrome DevTools là lợi thế.',
              'Có tinh thần học hỏi, teamwork tốt, chịu được áp lực công việc.',
            ],
            Categories: ['QA Tester'],
            Recruiter: {
              ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
              FullName: 'Lê Văn Nam',
              Position: 'Trưởng phòng nhân sự',
              Email: 'lengocanhpyne363@gmail.com',
              PhoneNumber: '+84393873632',
              AvatarUrl:
                'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
              Company: {
                Name: 'Công ty phần mềm FPT Software',
                LogoUrl:
                  'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//logo-fpt-software_043151683.png',
              },
            },
          },
        },
      ],
    },
  })
  async getFavoriteJobs(@Req() request: Request) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetJobFavorites(userId);
  }

  @Post('candidates/favorites')
  @ApiOperation({
    summary: 'Tạo danh sách các công việc ưa thích của ứng viên',
    description:
      'Đường dẫn này dùng để tạo ra các công việc ưa thích của ứng viên. Chỉ có ứng viên mới có quyền truy cập.',
  })
  @ApiBody({
    type: CreateJobFavoritesDto,
    description:
      'Dữ liệu cần gửi đi để tạo mới công việc ưa thích của ứng viên.',
  })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        success: true,
        message: 'Danh sách công việc đã được lưu thành công.',
      },
    },
  })
  @Roles(RoleEnum.CANDIDATE)
  async createJobFavoritesForCandidates(
    @Req() request: Request,
    @Body() createJobFavorites: CreateJobFavoritesDto,
  ) {
    const userId = (request.user as User).id;

    return this.jobsService.handleCreateJobFavorites(
      userId,
      createJobFavorites,
    );
  }

  @Delete('candidates/favorites')
  @ApiOperation({
    summary: 'Xoá công việc ưa thích của ứng viên',
    description:
      'Đường dẫn này dùng để xoá các công việc ưa thích của ứng viên. Chỉ có ứng viên mới có quyền truy cập.',
  })
  @ApiBody({
    type: DeleteJobFavoritesDto,
    description: 'Dữ liệu cần gửi đi để xoá các công việc ưa thích',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: {
        success: true,
        message: 'Các công việc đã lưu đã được xoá.',
      },
    },
  })
  @Roles(RoleEnum.CANDIDATE)
  async deleteJobFavoritesOfCandidates(
    @Body() deleteJobFavoritesDto: DeleteJobFavoritesDto,
    @Req() request: Request,
  ) {
    const userId = (request.user as User).id;

    return this.jobsService.handleDeleteJobFavorites(
      userId,
      deleteJobFavoritesDto,
    );
  }

  @Get(':jobId/applications')
  @UseGuards(SupabaseGuard, RoleAuthGuard)
  @ApiOperation({
    summary: 'Danh sách các đơn ứng tuyển cho một công việc',
    description:
      'Đường dẫn này dùng để lấy ra danh sách các đơn ứng tuyển của một công việc do nhà tuyển dụng đăng.',
  })
  @ApiParam({
    name: 'jobId',
    description: 'Mã định danh (ID) của công việc.',
    example: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
          JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
          Status: 'pending',
          AppliedAt: '2025-04-07T07:33:55.337',
          DeletedAt: null,
          ResumeUrl:
            'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
          Candidate: {
            ID: '891addf9-d54d-4c88-852d-fe96cb295536',
            Bio: 'Software developer with 3 years of experience in frontend development.',
            Level: 'senior',
            ResumeUrl: null,
            Certifications: [
              'AWS Certified Developer',
              'Google Cloud Associate',
            ],
            FullName: 'Lê Ngọc Anh',
            Email: 'lamduannhi0508@gmail.com',
            PhoneNumber: '+84393873631',
            AvatarUrl:
              'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
            Role: 'candidate',
            WorkExperiences: [
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
          },
        },
      ],
    },
  })
  @Roles(RoleEnum.RECRUITER)
  async getApplicationsOfJob(
    @Req() request: Request,
    @Param('jobId', ParseUUIDPipe) jobId: string,
  ) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetApplicationsOfJob(jobId, userId);
  }
}
