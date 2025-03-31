import { Injectable } from '@nestjs/common';
import { Users } from '@prisma/client';
import { omit } from 'lodash';
import { SupabaseService } from 'src/modules/supabase/supabase.service';

@Injectable()
export class UsersService {
  constructor(private readonly supabaseService: SupabaseService) {}

  public handleGetUsers = async () => {
    try {
      const supabase = this.supabaseService.getClient();

      const { data, error } = await supabase.from('Users').select('*');

      if (error) throw error;

      return data.map((data: Users) => omit(data, ['Password']));
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetUser = async (userId: string) => {
    try {
      const supabase = this.supabaseService.getClient();

      const { data, error } = await supabase
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .single();

      if (error) throw error;

      return data as Users;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
