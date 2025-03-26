import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import configurations from 'src/config/configurations';
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
      load: [configurations],
    }),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
