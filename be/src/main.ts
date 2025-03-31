import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

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
