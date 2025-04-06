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
import { ApiBearerAuth } from '@nestjs/swagger';
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { FileValidationDecorator, Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard } from 'src/libs/common/guards';
import { RoleEnum } from 'src/libs/common/utils';
import {
  CreateWorkExperiencesDto,
  UpdateWorkExperiencesDto,
} from 'src/modules/work-experiences/dtos';
import { WorkExperiencesService } from './work-experiences.service';

@Controller('work-experiences')
@UseGuards(RoleAuthGuard)
@Roles(RoleEnum.CANDIDATE)
@ApiBearerAuth()
export class WorkExperiencesController {
  constructor(
    private readonly workExperiencesService: WorkExperiencesService,
  ) {}

  @Post()
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
  async deleteWorkExperiences(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ) {
    const userId = (request.user as User).id;

    return this.workExperiencesService.handleDeleteWorkExperiences(id, userId);
  }

  @Patch(':id')
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
