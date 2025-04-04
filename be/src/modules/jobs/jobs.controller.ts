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
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard } from 'src/libs/common/guards';
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
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @Get()
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  async getJobs(@Req() request: Request) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetJobs(userId);
  }

  @Get('locations/:locationId')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  async searchJobsByLocations(@Param('locationId') locationId: string) {
    return this.jobsService.handleSearchJobsByLocations(locationId);
  }

  @Get('categories/:categoryName')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.CANDIDATE)
  async getJobsByCategory(@Param('categoryName') categoryName: string) {
    return this.jobsService.handleGetJobsByCategoryName(categoryName);
  }

  @Get('candidates/:candidateId/recommended-jobs')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.CANDIDATE)
  async getRecommendJobsForCandidate(@Req() request: Request) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetRecommendedJobsForCandidate(userId);
  }

  @Get(':id')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  async getJob(
    @Req() request: Request,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const userId = (request.user as User).id;

    return this.jobsService.handleGetJob(id, userId);
  }

  @Post()
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.RECRUITER)
  async createJob(@Body() createJobDto: CreateJobDto, @Req() request: Request) {
    return this.jobsService.handleCreateJob(
      createJobDto,
      (request.user as User).id,
    );
  }

  @Patch(':id')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.RECRUITER)
  async updateJob(
    @Param('id', ParseUUIDPipe) jobId: string,
    @Body() updateJobDto: UpdateJobDto,
  ) {
    return this.jobsService.handleUpdateJob(jobId, updateJobDto);
  }

  @Delete(':id')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.RECRUITER)
  async deleteJob(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ) {
    return this.jobsService.handleDeleteJob(id, (request.user as User).id);
  }

  @Patch('process/status')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN)
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
  @UseGuards(RoleAuthGuard)
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
  @UseGuards(RoleAuthGuard)
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
}
