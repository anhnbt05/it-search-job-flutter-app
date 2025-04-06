import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';

@Module({
  imports: [UploadsModule],
  controllers: [UsersController],
  providers: [UsersService, UploadsService],
})
export class UsersModule {}
