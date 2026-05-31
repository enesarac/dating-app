import type { Database, Tables, TablesInsert, TablesUpdate } from '@/types/database';

export type { Database, Tables, TablesInsert, TablesUpdate };

// ─── Row types ────────────────────────────────────────────────────────────────
export type ProfileRow = Tables<'profiles'>;
export type ProfileInsert = TablesInsert<'profiles'>;
export type ProfileUpdate = TablesUpdate<'profiles'>;

export type ProfilePhotoRow = Tables<'profile_photos'>;
export type ProfilePromptRow = Tables<'profile_prompts'>;
export type PreferencesRow = Tables<'preferences'>;

export type LikeRow = Tables<'likes'>;

export type MatchRow = Tables<'matches'>;
export type MatchParticipantRow = Tables<'match_participants'>;

export type MessageRow = Tables<'messages'>;
export type MessageInsert = TablesInsert<'messages'>;

export type BlockRow = Tables<'blocks'>;
export type ReportRow = Tables<'reports'>;
export type DeviceRow = Tables<'devices'>;
export type AppConfigRow = Tables<'app_config'>;
