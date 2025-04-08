import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Req,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
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
  CreateWorkExperiencesDto,
  UpdateWorkExperiencesDto,
} from 'src/modules/work-experiences/dtos';
import { WorkExperiencesService } from './work-experiences.service';

@Controller('work-experiences')
@UseGuards(SupabaseGuard, RoleAuthGuard)
@Roles(RoleEnum.CANDIDATE)
@ApiBearerAuth()
export class WorkExperiencesController {
  constructor(
    private readonly workExperiencesService: WorkExperiencesService,
  ) {}

  @Post()
  @ApiOperation({
    summary: 'Tạo mới kinh nghiệm làm việc',
    description:
      'Đường dẫn này dùng để tạo mới kinh nghiệm làm việc của ứng viên',
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    description: 'Dữ liệu tạo mới kinh nghiệm làm việc + logo công ty',
    required: true,
    schema: {
      type: 'object',
      properties: {
        CompanyName: {
          type: 'string',
          description: 'Tên của công ty',
          example: 'Công ty ABC',
        },
        Position: {
          type: 'string',
          description: 'Tên của vị trí',
          example: 'Software Developer',
        },
        StartDate: {
          type: 'string',
          format: 'date',
          description: 'Ngày bắt đầu vị trí kinh nghiệm (dạng ISO8061 string)',
          example: '2024-05-01T08:00:00Z',
        },
        EndDate: {
          type: 'string',
          format: 'date',
          description: 'Ngày kết thúc vị trí kinh nghiệm (nếu có)',
          example: '2024-07-01T08:00:00Z',
        },
        Descriptions: {
          type: 'string',
          example: '["Làm API", "Viết tài liệu"]',
          description:
            'Các trách nhiệm trong vị trí kinh nghiệm này. (Phải là chuỗi JSON hợp lệ)',
        },
        Location: {
          type: 'string',
          example: 'Hà Nội',
          description: 'Địa điểm làm vị trí kinh nghiệm này.',
        },
        JobType: {
          type: 'string',
          enum: ['full_time', 'part_time', 'free_lance', 'remote'],
          description: 'Hình thức làm việc',
        },
        logoFile: {
          type: 'string',
          format: 'binary',
          description: 'Logo của công ty',
        },
      },
      required: [
        'CompanyName',
        'Position',
        'StartDate',
        'Descriptions',
        'Location',
        'JobType',
        'logoFile',
      ],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Dữ liệu trả về sau khi tạo mới thành công.',
    schema: {
      example: {
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
      },
    },
  })
  @UseInterceptors(AnyFilesInterceptor())
  async createWorkExperience(
    @Req() request: Request,
    @Body() createWorkExperiencesDto: CreateWorkExperiencesDto,
    @FileValidationDecorator() files: Express.Multer.File[],
  ) {
    const candidateId = (request.user as User).id;

    if (!files?.length || !files?.find((file) => file.fieldname === 'logoFile'))
      throw new BadRequestException(
        `Bạn vui lòng cung cấp logo ảnh của công ty mà bạn làm việc.`,
      );

    const logoFile = files.find(
      (file) => file.fieldname === 'logoFile',
    ) as Express.Multer.File;

    return this.workExperiencesService.handleCreateWorkExperiencesForCandidate(
      candidateId,
      createWorkExperiencesDto,
      logoFile,
    );
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Xoá kinh nghiệm làm việc',
    description: 'Đường dẫn này dùng để xoá kinh nghiệm làm việc của ứng viên.',
  })
  @ApiResponse({
    status: 200,
    description: 'Dữ liệu trả về sau khi xoá thành công kinh nghiệm làm việc.',
    schema: {
      example: {
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
      },
    },
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) của kinh nghiệm làm việc',
    example: '01c17e17-b4b2-4f5a-a12b-c843f257b586',
  })
  async deleteWorkExperiences(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ) {
    const userId = (request.user as User).id;

    return this.workExperiencesService.handleDeleteWorkExperiences(id, userId);
  }

  @Patch(':id')
  @ApiOperation({
    summary: 'Thay đổi thông tin kinh nghiệm làm việc',
    description:
      'Đường dẫn này dùng để cập nhật thông tin kinh nghiệm làm việc của ứng viên.',
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) duy nhất của kinh nghiệm làm việc cần sửa.',
    example: '01c17e17-b4b2-4f5a-a12b-c843f257b586',
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    description:
      'Dữ liệu cần gửi đi để thay đổi thông tin kinh nghiệm làm việc.',
    required: true,
    schema: {
      type: 'object',
      properties: {
        CompanyName: {
          type: 'string',
          description: 'Tên của công ty (Nếu có, để trống nếu không thay đổi)',
          example: 'Công ty ABC',
        },
        Position: {
          type: 'string',
          description: 'Tên của vị tr (Nếu có, để trống nếu không thay đổi)',
          example: 'Software Developer',
        },
        StartDate: {
          type: 'string',
          format: 'date',
          description:
            'Ngày bắt đầu vị trí kinh nghiệm (dạng ISO8061 string), (Nếu có, để trống nếu không thay đổi)',
          example: '2024-05-01T08:00:00Z',
        },
        EndDate: {
          type: 'string',
          format: 'date',
          description:
            'Ngày kết thúc vị trí kinh nghiệm (nếu có), (Nếu có, để trống nếu không thay đổi)',
          example: '2024-07-01T08:00:00Z',
        },
        Descriptions: {
          type: 'string',
          example: '["Làm API", "Viết tài liệu"]',
          description:
            'Các trách nhiệm trong vị trí kinh nghiệm này. (Phải là chuỗi JSON hợp lệ), (Nếu có, để trống nếu không thay đổi)',
        },
        Location: {
          type: 'string',
          example: 'Hà Nội',
          description:
            'Địa điểm làm vị trí kinh nghiệm này. (Nếu có, để trống nếu không thay đổi)',
        },
        JobType: {
          type: 'string',
          enum: ['full_time', 'part_time', 'free_lance', 'remote'],
          description:
            'Hình thức làm việc, (Nếu có, để trống nếu không thay đổi)',
        },
        logoFile: {
          type: 'string',
          format: 'binary',
          description:
            'Logo của công ty, (Nếu có, để trống nếu không thay đổi)',
        },
      },
    },
  })
  @UseInterceptors(AnyFilesInterceptor())
  async updateWorkExperiences(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateWorkExperiencesDto: UpdateWorkExperiencesDto,
    @Req() request: Request,
    @FileValidationDecorator() files?: Express.Multer.File[],
  ) {
    const userId = (request.user as User).id;

    return this.workExperiencesService.handleUpdateWorkExperiences(
      id,
      updateWorkExperiencesDto,
      userId,
      files?.find((file) => file.fieldname === 'logoFile'),
    );
  }
}
