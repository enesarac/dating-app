import React from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  TouchableOpacity,
  type TouchableOpacityProps,
  type ViewStyle,
} from 'react-native';
import { colors, radius, spacing, typography } from '@/theme';
import { AppText } from './AppText';

type Variant = 'primary' | 'secondary' | 'ghost' | 'danger';
type Size = 'sm' | 'md' | 'lg';

type Props = TouchableOpacityProps & {
  label: string;
  variant?: Variant;
  size?: Size;
  loading?: boolean;
  fullWidth?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
};

const variantStyles: Record<Variant, { container: ViewStyle; textColor: string }> = {
  primary: {
    container: { backgroundColor: colors.brand },
    textColor: colors.textOnBrand,
  },
  secondary: {
    container: {
      backgroundColor: 'transparent',
      borderWidth: 1.5,
      borderColor: colors.brand,
    },
    textColor: colors.brand,
  },
  ghost: {
    container: { backgroundColor: 'transparent' },
    textColor: colors.brand,
  },
  danger: {
    container: { backgroundColor: colors.error },
    textColor: colors.textOnBrand,
  },
};

const sizeStyles: Record<Size, { container: ViewStyle; fontSize: number; paddingV: number }> = {
  sm: { container: { paddingVertical: spacing[1.5], paddingHorizontal: spacing[3] }, fontSize: 13, paddingV: spacing[1.5] },
  md: { container: { paddingVertical: spacing[3], paddingHorizontal: spacing[5] }, fontSize: 15, paddingV: spacing[3] },
  lg: { container: { paddingVertical: spacing[4], paddingHorizontal: spacing[6] }, fontSize: 17, paddingV: spacing[4] },
};

export function Button({
  label,
  variant = 'primary',
  size = 'md',
  loading = false,
  fullWidth = true,
  leftIcon,
  rightIcon,
  disabled,
  style,
  accessibilityLabel,
  ...rest
}: Props) {
  const vs = variantStyles[variant];
  const ss = sizeStyles[size];

  return (
    <TouchableOpacity
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel ?? label}
      accessibilityState={{ disabled: disabled || loading }}
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
      activeOpacity={0.75}
      disabled={disabled || loading}
      style={[
        styles.base,
        vs.container,
        ss.container,
        fullWidth && styles.fullWidth,
        (disabled || loading) && styles.disabled,
        style,
      ]}
      {...rest}
    >
      {loading ? (
        <ActivityIndicator color={vs.textColor} size="small" />
      ) : (
        <>
          {leftIcon}
          <AppText
            style={{ color: vs.textColor, fontSize: ss.fontSize, fontWeight: typography.weight.semibold }}
          >
            {label}
          </AppText>
          {rightIcon}
        </>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  base: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.lg,
    gap: spacing[2],
    minHeight: 44,
  },
  fullWidth: {
    alignSelf: 'stretch',
  },
  disabled: {
    opacity: 0.45,
  },
});
