import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { Candidates, WorkExperiences } from '@prisma/client';
import { SupabaseService } from 'src/modules/supabase/supabase.service';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UsersService } from 'src/modules/users/users.service';
import {
  CreateWorkExperiencesDto,
  UpdateWorkExperiencesDto,
} from 'src/modules/work-experiences/dtos';

@Injectable()
export class WorkExperiencesService {
  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly uploadsService: UploadsService,
    private readonly usersService: UsersService,
  ) {}

  public handleCreateWorkExperiencesForCandidate = async (
    userId: string,
    createWorkExperiencesDto: CreateWorkExperiencesDto,
    logoFile: Express.Multer.File,
  ) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data: candidate } = await supabaseAdmin
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!candidate)
        throw new NotFoundException(
          'Không tìm thấy thông tin ứng viên nào liên kết với bạn trong hệ thống. Vui lòng liên hệ với quản trị viên.',
        );

      const { url } = await this.uploadsService.uploadFile(logoFile, 'files');

      if (!url)
        throw new InternalServerErrorException(
          `Đã xảy ra lỗi trong quá trình tải file lên hệ thống. Vui lòng thử lại.`,
        );

      const { EndDate, StartDate, ...res } = createWorkExperiencesDto;

      if (new Date(StartDate).getTime() > new Date().getTime())
        throw new BadRequestException(
          'Ngày bắt đầu vị trí kinh nghiệm làm việc không thể lớn hơn ngày hiện tại.',
        );

      if (
        EndDate &&
        new Date(StartDate).getTime() > new Date(EndDate).getTime()
      )
        throw new BadRequestException(
          `Ngày bắt đầu vị trí kinh nghiệm làm việc phải nhỏ hơn so với ngày kết thúc vị trí kinh nghiệm làm việc.`,
        );

      const { error } = await supabaseAdmin.from('WorkExperiences').upsert(
        [
          {
            ...res,
            CompanyLogoUrl: url,
            CandidateID: candidate.ID,
            StartDate: new Date(StartDate),
            ...(EndDate && { EndDate: new Date(EndDate) }),
          },
        ],
        {
          onConflict: 'CompanyName,Position,CandidateID',
        },
      );

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm kinh nghiệm làm việc cho bạn. Vui lòng thử lại.',
        );
      }

      return this.usersService.handleGetUser(userId, userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleDeleteWorkExperiences = async (id: string, userId: string) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data } = await supabaseAdmin
        .from('WorkExperiences')
        .select('*')
        .eq('ID', id)
        .maybeSingle<WorkExperiences>();

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy bất kỳ kinh nghiệm làm việc nào có id '${id}' trong hệ thống.`,
        );

      if (data.CandidateID !== userId)
        throw new ForbiddenException(
          'Bạn không có quyền xoá kinh nghiệm làm việc của ứng viên khác.',
        );

      const { error } = await supabaseAdmin
        .from('WorkExperiences')
        .delete()
        .eq('ID', id);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình xoá kinh nghiệm làm việc của bạn. Vui lòng thử lại sau.',
        );
      }

      return this.usersService.handleGetUser(userId, userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleUpdateWorkExperiences = async (
    id: string,
    updateWorkExperiencesDto: UpdateWorkExperiencesDto,
    userId: string,
    logoFile?: Express.Multer.File,
  ) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data } = await supabaseAdmin
        .from('WorkExperiences')
        .select('*')
        .eq('ID', id)
        .maybeSingle<WorkExperiences>();

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy kinh nghiệm làm việc nào có id '${id}' trong hệ thống.`,
        );

      if (data && data.CandidateID !== userId)
        throw new ForbiddenException(
          'Bạn không có quyền xoá kinh nghiệm làm việc của người khác.',
        );

      let newLogoFileUrl = '';

      if (logoFile) {
        const { url } = await this.uploadsService.uploadFile(logoFile, 'files');

        newLogoFileUrl = url;
      }

      const { StartDate, EndDate, ...res } = updateWorkExperiencesDto;

      if (StartDate || EndDate) {
        if (StartDate && new Date(StartDate).getTime() > new Date().getTime())
          throw new BadRequestException(
            'Ngày bắt đầu mới cho kinh nghiệm làm việc này không thể lớn hơn ngày hiện tại.',
          );

        if (
          EndDate &&
          typeof EndDate === 'string' &&
          StartDate &&
          new Date(StartDate).getTime() > new Date(EndDate).getTime()
        )
          throw new BadRequestException(
            'Ngày bắt đầu mới cho kinh nghiệm làm việc này không thể lớn hơn ngày kết thúc mới.',
          );
      }

      const { error } = await supabaseAdmin
        .from('WorkExperiences')
        .update([
          {
            ...res,
            ...(newLogoFileUrl !== '' && { CompanyLogoUrl: newLogoFileUrl }),
            ...(StartDate && { StartDate: new Date(StartDate) }),
            ...((typeof EndDate === 'object' ||
              typeof EndDate === 'string') && {
              EndDate: EndDate === null ? null : new Date(EndDate),
            }),
          },
        ])
        .eq('ID', id);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi cập nhật kinh nghiệm làm việc cho bạn. Vui lòng thử lại.',
        );
      }

      return this.usersService.handleGetUser(userId, userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
