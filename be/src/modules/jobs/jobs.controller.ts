import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
} from '@nestjs/swagger';
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard, SupabaseGuard } from 'src/libs/common/guards';
import { RoleEnum } from 'src/libs/common/utils';
import {
  CreateJobDto,
  CreateJobFavoritesDto,
  DeleteJobFavoritesDto,
  ProcessJobStatusDto,
  UpdateJobDto,
} from 'src/modules/jobs/dtos';
import { JobsService } from './jobs.service';

@Controller('jobs')
@UseGuards(SupabaseGuard, RoleAuthGuard)
@ApiBearerAuth()
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
      ],
    },
  })
  async getJobs(@Req() request: Request) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetJobs(userId);
  }

  @Get('locations/:locationId')
  @ApiOperation({
    summary: 'Tìm kiếm công việc dựa trên địa điểm',
    description:
      'Đường dẫn này dùng để tìm kiếm các công việc dựa trên địa điểm',
  })
  @ApiResponse({
    status: 200,
    description:
      'Dữ liệu trả về sau khi tìm kiếm các công việc dựa trên địa điểm thành công.',
    schema: {
      example: [
        {
          ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
          Type: 'part_time',
          Level: 'intern',
          Title: 'Thực tập sinh Web Developer',
          Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
          Status: 'open',
          Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
          PostedAt: '2025-04-07T07:27:06.061',
          DeletedAt: null,
          ExpiredAt: '2025-06-15T23:59:59',
          Vacancies: 3,
          Description:
            'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          Recruiter: {
            ID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
            Position: 'Trưởng phòng nhân sự',
            FullName: 'Lê Văn Nam',
            PhoneNumber: '+84393873632',
            Email: 'lengocanhpyne363@gmail.com',
            Company: {
              Name: 'Công ty ABC',
              LogoUrl: null,
            },
          },
        },
      ],
    },
  })
  @ApiParam({
    name: 'locationId',
    description: 'Mã định danh (ID) duy nhất của địa điểm cần tìm kiếm',
    example: '90224a21-7468-4f06-8c05-0b2570e40177',
  })
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  async searchJobsByLocations(@Param('locationId') locationId: string) {
    return this.jobsService.handleSearchJobsByLocations(locationId);
  }

  @Get('categories/:categoryName')
  @ApiOperation({
    summary: 'Tìm kiếm công việc dựa trên danh mục',
    description:
      'Đường dẫn này dùng để tìm kiếm công việc dựa trên danh mục. Chỉ có ứng viên mới có quyền truy cập.',
  })
  @ApiParam({
    name: 'categoryName',
    description: 'Tên của danh mục cần tìm kiếm',
    example: 'Full Stack',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
          Type: 'part_time',
          Level: 'intern',
          Title: 'Thực tập sinh Web Developer',
          Salary: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
          Status: 'open',
          Address: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
          PostedAt: '2025-04-07T07:27:06.061',
          DeletedAt: null,
          ExpiredAt: '2025-06-15T23:59:59',
          Vacancies: 3,
          Description:
            'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
          JobBenefits: [
            'Có mentor hướng dẫn trong suốt thời gian thực tập.',
            'Hỗ trợ chi phí, có cơ hội trở thành nhân viên chính thức.',
            'Môi trường làm việc thân thiện, linh hoạt giờ giấc.',
          ],
          RecruiterID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          JobDescriptions: [
            'Có ít nhất 1 năm kinh nghiệm với Spring Boot (Java)',
            'Sử dụng thành thạo framework Next.js',
            'Có kiến thức cơ bản về Docker, CI/CD',
          ],
          JobRequirements: [
            'Sinh viên năm 3 trở lên chuyên ngành CNTT hoặc liên quan.',
            'Biết cơ bản HTML, CSS, JavaScript.',
            'Biết React là một lợi thế.',
            'Chăm chỉ, ham học hỏi, có tinh thần trách nhiệm.',
          ],
        },
        {
          ID: 'cf15bd11-16a3-46af-a832-4bd1d3af6230',
          Type: 'free_lance',
          Level: 'mid',
          Title: 'â',
          Salary: '100000 VND',
          Status: 'pending',
          Address:
            'Số 12 Nguyễn Văn Bảo, Phường 4, Quận Gò Vấp, Thành phố Hồ Chí Minh',
          PostedAt: '2025-04-07T08:03:48.601',
          DeletedAt: null,
          ExpiredAt: '2025-04-25T17:00:00',
          Vacancies: 2,
          Description: 'aaa',
          JobBenefits: ['d', 'e', 'ê', 'e'],
          RecruiterID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
          WorkingTimes: '8171ỵ',
          JobDescriptions: ['8ege', 'đe', 'dds', 'jsj'],
          JobRequirements: ['ưuhwes', 'd', 's', 'sei'],
        },
      ],
    },
  })
  @Roles(RoleEnum.CANDIDATE)
  async getJobsByCategory(@Param('categoryName') categoryName: string) {
    return this.jobsService.handleGetJobsByCategoryName(categoryName);
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
          Vacancies: 3,
          Type: 'part_time',
          WorkingTimes: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
          Status: 'open',
          PostedAt: '2025-04-07T07:27:06.061',
          ExpiredAt: '2025-06-15T23:59:59',
          Level: 'senior',
          DeletedAt: null,
          RecruiterID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
        },
        {
          ID: 'cf15bd11-16a3-46af-a832-4bd1d3af6230',
          Title: 'â',
          Description: 'aaa',
          Address:
            'Số 12 Nguyễn Văn Bảo, Phường 4, Quận Gò Vấp, Thành phố Hồ Chí Minh',
          Salary: '100000 VND',
          Vacancies: 2,
          Type: 'free_lance',
          WorkingTimes: '8171ỵ',
          Status: 'open',
          PostedAt: '2025-04-07T08:03:48.601',
          ExpiredAt: '2025-04-25T17:00:00',
          Level: 'mid',
          DeletedAt: null,
          RecruiterID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
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
        Status: 'pending',
        PostedAt: '2025-04-07T07:27:06.061',
        ExpiredAt: '2025-06-15T23:59:59',
        Level: 'intern',
        DeletedAt: null,
        RecruiterID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
      },
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
        RecruiterID: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
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
        },
      ],
    },
  })
  @ApiBody({
    type: ProcessJobStatusDto,
    description: 'Dữ liệu cần gửi đi để xử lý đơn ứng tuyển.',
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
