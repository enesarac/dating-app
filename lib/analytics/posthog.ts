import Constants from 'expo-constants';

const appEnv =
  (Constants.expoConfig?.extra?.appEnv ?? process.env.EXPO_PUBLIC_APP_ENV) || 'development';

const posthogKey = process.env.EXPO_PUBLIC_POSTHOG_KEY || '';
const posthogHost = process.env.EXPO_PUBLIC_POSTHOG_HOST || 'https://eu.i.posthog.com';

const isAnalyticsEnabled = appEnv !== 'development' && Boolean(posthogKey);

type EventProperties = Record<string, string | number | boolean | null | undefined>;

function capture(event: string, properties?: EventProperties): void {
  if (!isAnalyticsEnabled) return;

  // PostHog integration — initialised in app/_layout.tsx once
  // posthog.capture(event, properties);
  void event;
  void properties;
}

function identify(userId: string, traits?: EventProperties): void {
  if (!isAnalyticsEnabled) return;
  void userId;
  void traits;
}

function reset(): void {
  if (!isAnalyticsEnabled) return;
}

export const analytics = {
  capture,
  identify,
  reset,
  isEnabled: isAnalyticsEnabled,
  posthogKey,
  posthogHost,
};
