import React from 'react';
import {
  StyleSheet,
  TouchableOpacity,
  type TouchableOpacityProps,
  type ViewStyle,
} from 'react-native';
import { colors, palette } from '@/theme';

type Size = 'sm' | 'md' | 'lg';
type Variant = 'default' | 'ghost' | 'filled' | 'brand';

type Props = TouchableOpacityProps & {
  icon: React.ReactNode;
  size?: Size;
  variant?: Variant;
  accessibilityLabel: string;
  containerStyle?: ViewStyle;
};

const sizes: Record<Size, number> = { sm: 32, md: 44, lg: 52 };

const variantStyle: Record<Variant, ViewStyle> = {
  default: { backgroundColor: colors.bgSurface, borderWidth: 1, borderColor: colors.borderDefault },
  ghost: { backgroundColor: 'transparent' },
  filled: { backgroundColor: palette.gray200 },
  brand: { backgroundColor: colors.brand },
};

export function IconButton({
  icon,
  size = 'md',
  variant = 'default',
  accessibilityLabel,
  containerStyle,
  style,
  disabled,
  ...rest
}: Props) {
  const dim = sizes[size];
  return (
    <TouchableOpacity
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel}
      accessibilityState={{ disabled }}
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
      activeOpacity={0.7}
      disabled={disabled}
      style={[
        styles.base,
        variantStyle[variant],
        { width: dim, height: dim, borderRadius: dim / 2 },
        disabled && styles.disabled,
        containerStyle,
        style,
      ]}
      {...rest}
    >
      {icon}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  base: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  disabled: {
    opacity: 0.45,
  },
});
