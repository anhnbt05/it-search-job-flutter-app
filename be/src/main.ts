import { BadRequestException, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { collectMessages } from 'src/libs/common/utils';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
      exceptionFactory: (errors) => {
        const messages = errors.flatMap((err) => collectMessages(err));

        return new BadRequestException({
          message: messages,
          error: 'Bad Request',
          status: 400,
        });
      },
    }),
  );

  const configService = app.get(ConfigService);

  const PORT = configService.get<number>('port', 3001);

  const config = new DocumentBuilder()
    .setTitle('IT SEARCH JOB APP')
    .setDescription('It Search Job App Backend')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const documentFactory = () => SwaggerModule.createDocument(app, config);

  SwaggerModule.setup('api/v1/docs', app, documentFactory);

  await app.listen(PORT, () => {
    console.log(
      `Api documentation is running at: 'http://localhost:${PORT}/api/v1/docs'`,
    );
  });
}
bootstrap().catch((err) => {
  console.error('Error occurred when run application: ', err);
});
