import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron } from '@nestjs/schedule';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { fixInvalidUrls, normalizeUrl } from 'src/libs/common/utils';
import { PrismaService } from 'src/modules/prisma/prisma.service';

@Injectable()
export class AppService {
  private readonly excludedPaths: Set<string>;

  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    private readonly configService: ConfigService,
    private readonly prismaService: PrismaService,
  ) {
    const raw = this.configService.get<string>('storage_excluded_paths', '');

    const paths = raw
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    this.excludedPaths = new Set(paths);
  }

  getHello(): string {
    return `Chào mừng bạn đến với ứng dụng backend của đồ án 'Tìm kiếm việc làm cho dân IT' trong môn Nhập môn ứng dụng di động SE114.P21.`;
  }

  @Cron('0 0 * * *')
  async cleanupUnusedFiles() {
    const bucket = 'files';
    const baseUrl = `${this.configService.get<string>('supabase.url', '')}/storage/v1/object/public/${bucket}`;

    await fixInvalidUrls(this.prismaService);

    const { data: fileList, error } = await this.adminSupabaseClient.storage
      .from(bucket)
      .list('', {
        limit: 1000,
      });

    if (error) {
      console.error(
        'Không lấy được danh sách file từ Supabase: ',
        error.message,
      );

      return;
    }

    const allStorageUrls = fileList.map((file) =>
      normalizeUrl(`${baseUrl}/${file.name}`),
    );

    const dbUrls = await this.collectUrlsFromDb([
      { table: 'companies', column: 'LogoUrl' },
      { table: 'users', column: 'AvatarUrl' },
      { table: 'workExperiences', column: 'CompanyLogoUrl' },
      { table: 'applications', column: 'ResumeUrl' },
      { table: 'candidates', column: 'ResumeUrl' },
    ]);

    const urlsToDelete = allStorageUrls.filter((url) => !dbUrls.has(url));
    const pathsToDelete = urlsToDelete
      .map((url) => url.replace(`${baseUrl}/`, ''))
      .filter((path) => {
        const isExcluded = this.excludedPaths.has(path);
        const isProtectedExtension =
          path.endsWith('.xlsx') || path.endsWith('.pdf');

        return !isExcluded && !isProtectedExtension;
      });

    if (pathsToDelete.length === 0) {
      console.log('Không có file nào cần xoá.');
      return;
    }

    const { error: deleteError } = await this.adminSupabaseClient.storage
      .from(bucket)
      .remove(pathsToDelete);

    if (deleteError) {
      console.error('Lỗi khi xoá file:', deleteError.message);
    } else {
      console.log(`🗑️ Đã xoá ${pathsToDelete.length} file không còn dùng đến:`);
      pathsToDelete.forEach((file) => {
        console.log(`  - ${file}`);
      });
    }
  }

  private async collectUrlsFromDb(
    tableColumnPairs: { table: keyof PrismaService; column: string }[],
  ): Promise<Set<string>> {
    const dbUrls = new Set<string>();

    for (const { table, column } of tableColumnPairs) {
      const model = this.prismaService[table] as any;
      const records = await model.findMany();

      records.forEach((record: any) => {
        const url = record[column];
        if (url && typeof url === 'string') {
          dbUrls.add(normalizeUrl(url));
        }
      });
    }

    return dbUrls;
  }
}
