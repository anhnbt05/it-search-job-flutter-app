import {
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { Companies, Recruiters } from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { UpdateCompanyDto } from 'src/modules/companies/dtos';
import { UploadsService } from 'src/modules/uploads/uploads.service';

@Injectable()
export class CompaniesService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly uploadsService: UploadsService,
  ) {}

  public handleUpdateCompany = async (
    companyId: string,
    updateCompanyDto: UpdateCompanyDto,
    userId: string,
    logoFile?: Express.Multer.File,
  ) => {
    try {
      const { data: recruiter } = await this.anonSupabaseClient
        .from('Recruiters')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Recruiters>();

      if (!recruiter)
        throw new NotFoundException(
          `Không tìm thấy thông tin về hồ sơ nhà ứng tuyển của bạn. Vui lòng liên hệ với quản trị viên.`,
        );

      const { data: company } = await this.anonSupabaseClient
        .from('Companies')
        .select('*, CompanyLocations(*, Recruiters(*))')
        .eq('ID', companyId)
        .maybeSingle<any>();

      if (!company)
        throw new NotFoundException(
          `Không tìm thấy công ty có id '${companyId}' trong hệ thống.`,
        );

      const recruiterIds = company.CompanyLocations.flatMap(
        (cl: any) => cl.Recruiters,
      ).map((r: any) => r.ID);

      if (!recruiterIds.includes(recruiter.ID))
        throw new ForbiddenException(
          'Bạn chỉ có thể chỉnh sửa công ty của chính mình.',
        );

      let logoFileUrl: string = '';

      if (logoFile) {
        const { url } = await this.uploadsService.uploadFile(logoFile, 'files');

        if (url) logoFileUrl = url;
      }

      const { error } = await this.adminSupabaseClient
        .from('Companies')
        .update([
          {
            ...updateCompanyDto,
            ...(logoFileUrl && { LogoUrl: logoFileUrl }),
          },
        ])
        .eq('ID', companyId);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi cập nhật thông tin cho công ty của bạn. Vui lòng thử lại sau.',
        );
      }

      return {
        success: true,
        message: 'Đã cập nhật thành công thông tin mới về công ty của bạn.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
