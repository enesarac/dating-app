import { createClient } from '@supabase/supabase-js';
import Constants from 'expo-constants';
import type { Database } from '@/types/database';

const supabaseUrl = (Constants.expoConfig?.extra?.supabaseUrl ??
  process.env.EXPO_PUBLIC_SUPABASE_URL) as string;

const supabasePublishableKey = (Constants.expoConfig?.extra?.supabasePublishableKey ??
  process.env.EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY) as string;

if (__DEV__ && (!supabaseUrl || !supabasePublishableKey)) {
  console.warn(
    '[Supabase] EXPO_PUBLIC_SUPABASE_URL or EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY is missing. ' +
      'Copy .env.example to .env.local and fill in the values.',
  );
}

export const supabase = createClient<Database>(supabaseUrl, supabasePublishableKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: false,
  },
});
