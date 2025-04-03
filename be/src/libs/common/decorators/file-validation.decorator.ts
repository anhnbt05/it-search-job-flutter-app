import {
  BadRequestException,
  createParamDecorator,
  ExecutionContext,
} from '@nestjs/common';

export const FileValidationDecorator = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();

    const files = request.files;

    if (!files) return files;

    if (files.avatar && files.avatar[0]) {
      const mimeType = files.avatar[0].mimetype;
      if (!mimeType.startsWith('image/')) {
        throw new BadRequestException(
          'Avatar must be an image (JPG, JPEG, PNG).',
        );
      }
    }

    if (files.logoFile && files.logoFile[0]) {
      const mimeType = files.logoFile[0].mimetype;

      if (!mimeType.startsWith('image/')) {
        throw new BadRequestException(
          'Logo file must be an image (JPG, JPEG, PNG).',
        );
      }
    }

    if (files.resumeFile && files.resumeFile[0]) {
      const mimeType = files.resumeFile[0].mimetype;
      if (
        !mimeType.match(
          /(pdf|msword|vnd.openxmlformats-officedocument.wordprocessingml.document)$/,
        )
      ) {
        throw new BadRequestException('Resume file must be a PDF or DOCX.');
      }
    }

    return files;
  },
);
