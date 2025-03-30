import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';
import { createClient, User } from '@supabase/supabase-js';
import * as bcryptjs from 'bcryptjs';

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
  const hashedPassword = await hashPassword('admin123');

  const email = 'admin123@gmail.com';

  const { data: userData } = await supabaseAdmin.auth.admin.listUsers();

  const existingUser = userData.users.find(
    (user: User) => user.email === email,
  );

  let userId: string;

  if (existingUser) {
    userId = existingUser.id;

    await supabaseAdmin.auth.admin.updateUserById(existingUser.id, {
      app_metadata: {
        role: 'admin',
      },
    });
  } else {
    const { data, error } = await supabaseAdmin.auth.signUp({
      email,
      password: 'admin123',
    });

    if (error) throw new Error(error.message);

    if (!data.user) throw new Error('User creation failed');

    userId = data.user.id;

    await supabaseAdmin.auth.admin.updateUserById(data.user.id, {
      app_metadata: {
        role: 'admin',
      },
    });
  }

  await prisma.users.upsert({
    where: { Email: email },
    update: {
      ID: userId,
      Password: hashedPassword,
      AvatarUrl:
        'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
      PhoneNumber: '+840393874567',
      FullName: 'John Doe',
      Role: 'ADMIN',
      IsEmailVerified: true,
    },
    create: {
      ID: userId,
      Email: email,
      Password: hashedPassword,
      AvatarUrl:
        'https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png',
      PhoneNumber: '+840393874567',
      FullName: 'John Doe',
      Role: 'ADMIN',
      IsEmailVerified: true,
    },
  });

  const response = await fetch('https://provinces.open-api.vn/api/p');

  const provinces = ((await response.json()) as Province[]).map((p) => p.name);

  const { data: existingRecords, error } = await supabaseAdmin
    .from('Locations')
    .select('Name')
    .in('Name', provinces);

  if (error) throw new Error(error.message);

  const existingNames = new Set(existingRecords.map((r) => r.Name));

  const provincesToInsert = provinces
    .filter((province) => !existingNames.has(province))
    .map((province) => ({
      Name: province,
      Country: 'Việt Nam',
    }));

  if (provincesToInsert.length > 0) {
    const { error: insertError } = await supabaseAdmin
      .from('Locations')
      .insert(provincesToInsert);

    if (insertError) throw new Error(insertError.message);
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
    console.log('Seeding done!');
  });
