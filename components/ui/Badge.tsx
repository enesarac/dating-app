import React from 'react';
import { StyleSheet, View, type ViewStyle } from 'react-native';
import { colors, radius, spacing, typography } from '@/theme';
import { AppText } from './AppText';

type Variant = 'default' | 'brand' | 'success' | 'warning' | 'error' | 'info';
type Size = 'sm' | 'md';

type Props = {
  label: string;
  variant?: Variant;
  size?: Size;
  style?: ViewStyle;
};

const variantColors: Record<Variant, { bg: string; text: string }> = {
  default: { bg: colors.bgSurface, text: colors.textSecondary },
  brand: { bg: colors.brandLight, text: colors.brandDark },
  success: { bg: colors.successLight, text: colors.success },
  warning: { bg: colors.warningLight, text: colors.warning },
  error: { bg: colors.errorLight, text: colors.error },
  info: { bg: colors.infoLight, text: colors.info },
};

export function Badge({ label, variant = 'default', size = 'md', style }: Props) {
  const vc = variantColors[variant];
  const isSmall = size === 'sm';

  return (
    <View
      style={[
        styles.base,
        {
          backgroundColor: vc.bg,
          paddingHorizontal: isSmall ? spacing[1.5] : spacing[2],
          paddingVertical: isSmall ? spacing[0.5] : spacing[1],
        },
        style,
      ]}
    >
      <AppText
        style={{
          color: vc.text,
          fontSize: isSmall ? typography.size.xs : typography.size.sm,
          fontWeight: typography.weight.semibold,
          lineHeight: isSmall ? 14 : 16,
        }}
      >
        {label}
      </AppText>
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: radius.full,
    alignSelf: 'flex-start',
  },
});
