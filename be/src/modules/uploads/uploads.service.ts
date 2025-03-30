import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseService } from 'src/modules/supabase/supabase.service';

@Injectable()
export class UploadsService {
  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly configService: ConfigService,
  ) {}

  public uploadFile = async (file: Express.Multer.File, bucket: string) => {
    try {
      const supabase = this.supabaseService.getClient();

      const fileName = `${Date.now()}-${file.originalname}`;

      const { error } = await supabase.storage
        .from(bucket)
        .upload(fileName, new Uint8Array(file.buffer), {
          contentType: file.mimetype,
        });

      if (error) throw new Error(error.message);

      return {
        url: `${this.configService.get<string>('supabase.url', '')}/storage/v1/object/public/${bucket}/${fileName}`,
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
