import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import * as fs from 'fs';
import * as path from 'path';
import * as mime from 'mime-types';

@Injectable()
export class UploadsService {
  constructor(
    private readonly configService: ConfigService,
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
  ) {}

  public uploadFile = async (file: Express.Multer.File, bucket: string) => {
    try {
      const sanitizedOriginalName = file.originalname
        .toLowerCase()
        .replace(/[^a-z0-9.-]/g, '_');

      const fileName = `${Date.now()}-${sanitizedOriginalName}`;

      const { error } = await this.adminSupabaseClient.storage
        .from(bucket)
        .upload(fileName, new Uint8Array(file.buffer), {
          contentType: file.mimetype,
        });

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình tải file lên cloud.',
        );
      }

      return {
        url: `${this.configService.get<string>('supabase.url', '')}/storage/v1/object/public/${bucket}/${fileName}`,
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleUploadFilePath = async (filePath: string, bucket: string) => {
    try {
      if (!fs.existsSync(filePath)) {
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi tạo file báo cáo. Vui lòng thử lại.',
        );
      }

      const fileBuffer = fs.readFileSync(filePath);

      const fileName = path.basename(filePath);

      const contentType = mime.lookup(filePath) || 'application/octet-stream';

      const { error } = await this.adminSupabaseClient.storage
        .from(bucket)
        .upload(fileName, fileBuffer, {
          contentType,
        });

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình tải file lên cloud.',
        );
      }

      return {
        url: `${this.configService.get<string>('supabase.url', '')}/storage/v1/object/public/${bucket}/${fileName}`,
      };
    } catch (err) {
      if (err.code === 'ENOENT') {
        console.error('[ENOENT]', err);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi tạo file báo cáo. Vui lòng thử lại.',
        );
      }

      console.error('[UPLOAD ERROR]', err);
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi không xác định trong quá trình upload.',
      );
    }
  };
}
