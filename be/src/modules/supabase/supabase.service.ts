import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService implements OnModuleInit {
  private supabase: SupabaseClient;
  private supabaseAdmin: SupabaseClient;

  constructor(private readonly configService: ConfigService) {
    this.supabase = createClient(
      configService.get<string>('supabase.url', ''),
      configService.get<string>('supabase.key', ''),
    );

    this.supabaseAdmin = createClient(
      configService.get<string>('supabase.url', ''),
      configService.get<string>('supabase.service_role_key', ''),
    );
  }

  onModuleInit() {
    console.log('🔗 Supabase connected!');
  }

  getClient(): SupabaseClient {
    return this.supabase;
  }

  getAdminClient(): SupabaseClient {
    return this.supabaseAdmin;
  }
}
