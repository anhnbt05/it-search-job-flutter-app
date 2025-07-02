export default () => ({
  port: parseInt(process.env.PORT ?? '3001', 10) || 3001,
  supabase: {
    url: process.env.SUPABASE_URL,
    service_role_key: process.env.SUPABASE_SERVICE_ROLE_KEY,
    anon_key: process.env.SUPABASE_ANON_KEY,
  },
  default_user_logo: process.env.DEFAULT_LOGO_USER,
  redis_url: process.env.REDIS_URL,
  mailer: {
    host: process.env.MAILER_HOST,
    port: parseInt(process.env.MAILER_PORT ?? '587', 10),
    user: process.env.MAILER_USER,
    password: process.env.MAILER_PASSWORD,
  },
  application: {
    name: process.env.APPLICATION_NAME,
    logo_url: process.env.APPLICATION_LOGO_URL,
    description: process.env.APPLICATION_DESCRIPTION,
    icon_url: process.env.APPLICATION_ICON_URL,
  },
  admin: {
    email: process.env.ADMIN_EMAIL,
    phone_number: process.env.ADMIN_PHONE_NUMBER,
    full_name: process.env.ADMIN_FULL_NAME,
  },
  onesignal: {
    app_id: process.env.ONESIGNAL_APP_ID,
    api_key: process.env.ONESIGNAL_API_KEY,
  },
  storage_excluded_paths: process.env.STORAGE_EXCLUDED_PATHS,
});
