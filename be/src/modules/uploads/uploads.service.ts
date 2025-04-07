import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';

@Injectable()
export class UploadsService {
  constructor(
    private readonly configService: ConfigService,
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
  ) {}

  public uploadFile = async (file: Express.Multer.File, bucket: string) => {
    try {
      const fileName = `${Date.now()}-${file.originalname}`;

      const { error } = await this.adminSupabaseClient.storage
        .from(bucket)
        .upload(fileName, new Uint8Array(file.buffer), {
          contentType: file.mimetype,
        });

      if (error)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình tải file lên cloud.',
        );

      return {
        url: `${this.configService.get<string>('supabase.url', '')}/storage/v1/object/public/${bucket}/${fileName}`,
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
