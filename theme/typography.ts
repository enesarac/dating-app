import { Platform, type TextStyle } from 'react-native';

const fontFamily = Platform.select({
  ios: {
    regular: 'System',
    medium: 'System',
    semibold: 'System',
    bold: 'System',
  },
  android: {
    regular: 'sans-serif',
    medium: 'sans-serif-medium',
    semibold: 'sans-serif-medium',
    bold: 'sans-serif-bold',
  },
  default: {
    regular: 'System',
    medium: 'System',
    semibold: 'System',
    bold: 'System',
  },
})!;

export const typography = {
  // Font sizes
  size: {
    xs: 11,
    sm: 13,
    md: 15,
    lg: 17,
    xl: 20,
    '2xl': 24,
    '3xl': 28,
    '4xl': 34,
    '5xl': 40,
  },

  // Line heights
  lineHeight: {
    tight: 1.2,
    snug: 1.35,
    normal: 1.5,
    relaxed: 1.625,
  },

  // Font weights (as strings for React Native)
  weight: {
    regular: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
    extrabold: '800',
  },

  fontFamily,
} as const;

export type TextVariant =
  | 'largeTitle'
  | 'title1'
  | 'title2'
  | 'title3'
  | 'headline'
  | 'body'
  | 'callout'
  | 'subhead'
  | 'footnote'
  | 'caption1'
  | 'caption2';

export const textStyles: Record<
  TextVariant,
  { fontSize: number; fontWeight: TextStyle['fontWeight']; lineHeight: number }
> = {
  largeTitle: {
    fontSize: typography.size['4xl'],
    fontWeight: typography.weight.bold,
    lineHeight: typography.size['4xl'] * typography.lineHeight.tight,
  },
  title1: {
    fontSize: typography.size['3xl'],
    fontWeight: typography.weight.bold,
    lineHeight: typography.size['3xl'] * typography.lineHeight.tight,
  },
  title2: {
    fontSize: typography.size['2xl'],
    fontWeight: typography.weight.semibold,
    lineHeight: typography.size['2xl'] * typography.lineHeight.snug,
  },
  title3: {
    fontSize: typography.size.xl,
    fontWeight: typography.weight.semibold,
    lineHeight: typography.size.xl * typography.lineHeight.snug,
  },
  headline: {
    fontSize: typography.size.lg,
    fontWeight: typography.weight.semibold,
    lineHeight: typography.size.lg * typography.lineHeight.normal,
  },
  body: {
    fontSize: typography.size.md,
    fontWeight: typography.weight.regular,
    lineHeight: typography.size.md * typography.lineHeight.normal,
  },
  callout: {
    fontSize: typography.size.md,
    fontWeight: typography.weight.regular,
    lineHeight: typography.size.md * typography.lineHeight.normal,
  },
  subhead: {
    fontSize: typography.size.sm,
    fontWeight: typography.weight.regular,
    lineHeight: typography.size.sm * typography.lineHeight.normal,
  },
  footnote: {
    fontSize: typography.size.sm,
    fontWeight: typography.weight.regular,
    lineHeight: typography.size.sm * typography.lineHeight.normal,
  },
  caption1: {
    fontSize: typography.size.xs,
    fontWeight: typography.weight.regular,
    lineHeight: typography.size.xs * typography.lineHeight.normal,
  },
  caption2: {
    fontSize: typography.size.xs,
    fontWeight: typography.weight.regular,
    lineHeight: typography.size.xs * typography.lineHeight.normal,
  },
};
