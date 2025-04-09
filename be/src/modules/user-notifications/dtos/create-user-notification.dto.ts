import { NotificationType } from '@prisma/client';
import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsObject,
  IsString,
} from 'class-validator';

export class CreateUserNotificationDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Content!: string[];

  @IsEnum(NotificationType)
  readonly Type!: NotificationType;

  @IsObject()
  readonly metadata!: Record<string, any>;
}
