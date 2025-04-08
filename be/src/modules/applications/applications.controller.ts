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
  UseInterceptors,
} from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
} from '@nestjs/swagger';
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { FileValidationDecorator, Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard, SupabaseGuard } from 'src/libs/common/guards';
import { RoleEnum } from 'src/libs/common/utils';
import {
  CreateApplicationDto,
  ProcessApplicationsDto,
} from 'src/modules/applications/dtos';
import { ApplicationsService } from './applications.service';

@Controller('applications')
@UseGuards(SupabaseGuard, RoleAuthGuard)
@ApiBearerAuth()
export class ApplicationsController {
  constructor(private readonly applicationsService: ApplicationsService) {}

  @Get()
  @ApiOperation({
    summary: 'Danh sách các đơn ứng tuyển của ứng viên',
    description:
      'Đường dẫn này dùng để lấy danh sách các đơn ứng tuyển hiện có của ứng viên.',
  })
  @Roles(RoleEnum.CANDIDATE)
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
          ResumeUrl:
            'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
          Status: 'pending',
          AppliedAt: '2025-04-07T07:33:55.337',
          DeletedAt: null,
          CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
          JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
        },
        {
          ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
          ResumeUrl:
            'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
          Status: 'pending',
          AppliedAt: '2025-04-07T07:33:55.337',
          DeletedAt: null,
          CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
          JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
        },
      ],
    },
  })
  @ApiResponse({
    status: 200,
  })
  @Roles(RoleEnum.CANDIDATE)
  async getApplications(@Req() request: Request) {
    const userId = (request.user as User).id;

    return this.applicationsService.handleGetApplications(userId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Lấy chi tiết thông tin đơn ứng tuyển',
    description: 'Đường dẫn này dùng để lấy chi tiết thông tin đơn ứng tuyển.',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) duy nhất của đơn ứng tuyển.',
    example: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
  })
  @Roles(RoleEnum.CANDIDATE)
  @ApiResponse({
    status: 200,
    schema: {
      example: {
        ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
        ResumeUrl:
          'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
        Status: 'pending',
        AppliedAt: '2025-04-07T07:33:55.337',
        Job: {
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
            'Tham gia phát triển giao diện người dùng bằng HTML, CSS, JavaScript.',
            'Học hỏi và áp dụng React vào các dự án nội bộ.',
            'Hỗ trợ kiểm thử và xử lý lỗi trên hệ thống.',
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
    },
  })
  async getApplication(
    @Req() request: Request,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const userId = (request.user as User).id;

    return this.applicationsService.handleGetApplication(userId, id);
  }

  @Post()
  @Roles(RoleEnum.CANDIDATE)
  @UseInterceptors(AnyFilesInterceptor())
  @ApiOperation({
    summary: 'Tạo đơn ứng tuyển mới',
    description: 'Đường dẫn này dùng để tạo mới đơn ứng tuyển cho ứng viên.',
  })
  @ApiResponse({
    status: 201,
    schema: {
      example: [
        {
          ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
          ResumeUrl:
            'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
          Status: 'pending',
          AppliedAt: '2025-04-07T07:33:55.337',
          DeletedAt: null,
          CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
          JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
        },
        {
          ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
          ResumeUrl:
            'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
          Status: 'pending',
          AppliedAt: '2025-04-07T07:33:55.337',
          DeletedAt: null,
          CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
          JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
        },
      ],
    },
  })
  async createApplication(
    @Req() request: Request,
    @Body() createApplicationDto: CreateApplicationDto,
    @FileValidationDecorator() files?: Express.Multer.File[],
  ) {
    const userId = (request.user as User).id;

    return this.applicationsService.handleCreateApplication(
      userId,
      createApplicationDto,
      files,
    );
  }

  @Delete(':id')
  @Roles(RoleEnum.CANDIDATE)
  @ApiOperation({
    summary: 'Xoá mềm đơn ứng tuyển',
    description: 'Đường dẫn này dùng để xoá mềm đơn ứng tuyển của ứng viên',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) duy nhất của đơn ứng tuyển',
    example: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: [
        {
          ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
          ResumeUrl:
            'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
          Status: 'pending',
          AppliedAt: '2025-04-07T07:33:55.337',
          DeletedAt: null,
          CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
          JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
        },
        {
          ID: 'b820f7cb-dbf7-4897-8962-f3d2b8e93815',
          ResumeUrl:
            'https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744011229465-1743210197848-Intern Software Engineer (Backend Developer) Resume - Le Ngoc Anh.pdf',
          Status: 'pending',
          AppliedAt: '2025-04-07T07:33:55.337',
          DeletedAt: null,
          CandidateID: '891addf9-d54d-4c88-852d-fe96cb295536',
          JobID: 'c1f917bf-f4ab-434a-a446-d4dfded60687',
        },
      ],
    },
  })
  async deleteApplication(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ) {
    const userId = (request.user as User).id;

    return this.applicationsService.handleDeleteApplication(id, userId);
  }

  @Patch('process')
  @ApiOperation({
    summary: 'Xử lý đơn ứng tuyển của ứng viên',
    description:
      'Đường dẫn này dùng để xử lý đơn ứng tuyển của ứng viên. Chỉ có nhà tuyển dụng mới có quyền truy cập.',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: {
        success: true,
        message: 'Xử lý các đơn ứng tuyển thành công.',
      },
    },
  })
  @ApiBody({
    type: ProcessApplicationsDto,
    description: 'Dữ liệu cần gửi đi để xử lý đơn ứng tuyển của các ứng viên.',
  })
  @Roles(RoleEnum.RECRUITER)
  async processApplications(
    @Req() request: Request,
    @Body() processApplicationsDto: ProcessApplicationsDto,
  ) {
    const userId = (request.user as User).id;

    return this.applicationsService.handleProcessApplications(
      userId,
      processApplicationsDto,
    );
  }
}
