import { Platform } from 'react-native';

type Shadow = {
  shadowColor: string;
  shadowOffset: { width: number; height: number };
  shadowOpacity: number;
  shadowRadius: number;
  elevation: number;
};

function makeShadow(height: number, radius: number, opacity: number, elevation: number): Shadow {
  return Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height },
      shadowOpacity: opacity,
      shadowRadius: radius,
      elevation: 0,
    },
    android: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height },
      shadowOpacity: opacity,
      shadowRadius: radius,
      elevation,
    },
    default: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height },
      shadowOpacity: opacity,
      shadowRadius: radius,
      elevation,
    },
  })!;
}

export const shadows = {
  none: makeShadow(0, 0, 0, 0),
  xs: makeShadow(1, 2, 0.05, 1),
  sm: makeShadow(1, 4, 0.08, 2),
  md: makeShadow(2, 8, 0.1, 4),
  lg: makeShadow(4, 12, 0.12, 8),
  xl: makeShadow(8, 24, 0.15, 12),
  card: makeShadow(2, 8, 0.08, 3),
  profileCard: makeShadow(4, 16, 0.12, 6),
  bottomSheet: makeShadow(-2, 12, 0.15, 16),
} as const;

export type ShadowToken = keyof typeof shadows;
