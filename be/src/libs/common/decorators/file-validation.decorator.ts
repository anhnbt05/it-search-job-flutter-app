import {
  BadRequestException,
  createParamDecorator,
  ExecutionContext,
} from '@nestjs/common';

export const FileValidationDecorator = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();

    const files = request.files as Express.Multer.File[];

    if (!files) return files;

    if (files?.find((file) => file.fieldname === 'avatarFile')) {
      const avatarFile = files?.find((file) => file.fieldname === 'avatarFile');

      const mimeType = avatarFile?.mimetype;

      if (!mimeType?.startsWith('image/')) {
        throw new BadRequestException(
          'Định dạng của ảnh đại diện phải là JPG, JPEG hoặc PNG.',
        );
      }
    }

    if (files?.find((file) => file.fieldname === 'logoFile')) {
      const avatarFile = files?.find((file) => file.fieldname === 'logoFile');

      const mimeType = avatarFile?.mimetype;

      if (!mimeType?.startsWith('image/')) {
        throw new BadRequestException(
          'Định dạng của logo phải là JPG, JPEG hoặc PNG.',
        );
      }
    }

    if (files?.find((file) => file.fieldname === 'resumeFile')) {
      const resumeFile = files?.find((file) => file.fieldname === 'resumeFile');

      const mimeType = resumeFile?.mimetype;

      if (
        !mimeType?.match(
          /(pdf|msword|vnd.openxmlformats-officedocument.wordprocessingml.document)$/,
        )
      ) {
        throw new BadRequestException(
          'Định dạng của file CV phải là .pdf hoặc .docx',
        );
      }
    }

    return files;
  },
);
