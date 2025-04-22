import { InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';
import { createClient, User } from '@supabase/supabase-js';
import * as bcryptjs from 'bcryptjs';
import { RoleEnum } from '../src/libs/common/utils';
import { Categories, Notifications } from './seeds';

export type Province = {
  name: string;
  code: number;
  division_type: string;
  codename: string;
  phone_code: number;
  districts: string[];
};

export const hashPassword = async (password: string) => {
  const salt = await bcryptjs.genSalt();

  const hashed = await bcryptjs.hash(password, salt);

  return hashed;
};

const prisma = new PrismaClient();

const configService = new ConfigService();

const supabaseAdmin = createClient(
  configService.get<string>('SUPABASE_URL', ''),
  configService.get<string>('SUPABASE_SERVICE_ROLE_KEY', ''),
);

async function main() {
  const hashedPassword = await hashPassword(
    configService.get<string>('ADMIN_PASSWORD', ''),
  );

  const email = configService.get<string>('ADMIN_EMAIL', '');

  const { data: userData } = await supabaseAdmin.auth.admin.listUsers();

  const existingUser = userData.users.find(
    (user: User) => user.email === email,
  );

  let userId: string;

  if (existingUser) {
    userId = existingUser.id;

    await supabaseAdmin.auth.admin.updateUserById(existingUser.id, {
      app_metadata: {
        role: configService.get<string>('ADMIN_ROLE_NAME', ''),
      },
    });
  } else {
    const { data, error } = await supabaseAdmin.auth.signUp({
      email,
      password: configService.get<string>('ADMIN_PASSWORD', ''),
    });

    if (error || !data.user)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi tạo mới tài khoản quản trị viên. Vui lòng thử lại.',
      );

    userId = data.user.id;

    await supabaseAdmin.auth.admin.updateUserById(data.user.id, {
      app_metadata: {
        role: configService.get<string>('ADMIN_ROLE_NAME', ''),
      },
    });
  }

  await prisma.users.upsert({
    where: { Email: email },
    update: {
      ID: userId,
      Password: hashedPassword,
      AvatarUrl: configService.get<string>('DEFAULT_LOGO_USER', ''),
      PhoneNumber: configService.get<string>('ADMIN_PHONE_NUMBER', ''),
      FullName: configService.get<string>('ADMIN_FULL_NAME', ''),
      Role: RoleEnum.ADMIN,
      IsEmailVerified: true,
    },
    create: {
      ID: userId,
      Email: email,
      Password: hashedPassword,
      AvatarUrl: configService.get<string>('DEFAULT_LOGO_USER', ''),
      PhoneNumber: configService.get<string>('ADMIN_PHONE_NUMBER', ''),
      FullName: configService.get<string>('ADMIN_FULL_NAME', ''),
      Role: RoleEnum.ADMIN,
      IsEmailVerified: true,
    },
  });

  const response = await fetch(configService.get<string>('API_PROVINCES', ''));

  const provinces = ((await response.json()) as Province[]).map((p) => ({
    Name: p.name,
    Country: 'Việt Nam',
  }));

  if (provinces.length) {
    await Promise.all(
      provinces.map((province) =>
        prisma.locations.upsert({
          where: { Name: province.Name },
          update: { Country: province.Country },
          create: {
            Name: province.Name,
            Country: province.Country,
          },
        }),
      ),
    );
  }

  if (Categories.length) {
    await Promise.all(
      Categories.map(async (category) =>
        prisma.categories.upsert({
          where: { CategoryName: category },
          update: {},
          create: {
            CategoryName: category,
          },
        }),
      ),
    );
  }

  if (Notifications.length) {
    await Promise.all(
      Notifications.map(async ({ Title, Type }) => {
        return await prisma.notifications.upsert({
          where: {
            Type,
          },
          update: {
            Title,
          },
          create: {
            Title,
            Type,
          },
        });
      }),
    );
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  // eslint-disable-next-line @typescript-eslint/no-misused-promises
  .finally(async () => {
    await prisma.$disconnect();
    console.log('Thêm dữ liệu mẫu vào cơ sở dữ liệu thành công.');
  });
