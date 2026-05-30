export const palette = {
  // Brand
  pink50: '#FFF0F5',
  pink100: '#FFD6E7',
  pink200: '#FFB3D1',
  pink300: '#FF8AB8',
  pink400: '#FF609E',
  pink500: '#FF3B82',
  pink600: '#E01F6A',
  pink700: '#B81556',
  pink800: '#8F0D42',
  pink900: '#66082F',

  // Neutral
  white: '#FFFFFF',
  gray50: '#F9FAFB',
  gray100: '#F3F4F6',
  gray200: '#E5E7EB',
  gray300: '#D1D5DB',
  gray400: '#9CA3AF',
  gray500: '#6B7280',
  gray600: '#4B5563',
  gray700: '#374151',
  gray800: '#1F2937',
  gray900: '#111827',
  black: '#000000',

  // Semantic
  red400: '#F87171',
  red500: '#EF4444',
  green400: '#4ADE80',
  green500: '#22C55E',
  amber400: '#FBBF24',
  amber500: '#F59E0B',
  blue400: '#60A5FA',
  blue500: '#3B82F6',
} as const;

export const colors = {
  // Brand
  brand: palette.pink500,
  brandLight: palette.pink100,
  brandDark: palette.pink700,

  // Text
  textPrimary: palette.gray900,
  textSecondary: palette.gray500,
  textDisabled: palette.gray400,
  textInverse: palette.white,
  textOnBrand: palette.white,

  // Background
  bgBase: palette.white,
  bgSurface: palette.gray50,
  bgElevated: palette.white,
  bgOverlay: 'rgba(0,0,0,0.5)',

  // Border
  borderDefault: palette.gray200,
  borderStrong: palette.gray300,
  borderFocus: palette.pink500,

  // Status
  error: palette.red500,
  errorLight: '#FEF2F2',
  success: palette.green500,
  successLight: '#F0FDF4',
  warning: palette.amber500,
  warningLight: '#FFFBEB',
  info: palette.blue500,
  infoLight: '#EFF6FF',

  // Match / Premium UX
  likeGreen: palette.green400,
  passGray: palette.gray400,
  superLikePurple: '#A855F7',
  matchGold: '#F59E0B',
} as const;

export type ColorToken = keyof typeof colors;
