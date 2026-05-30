import React from 'react';
import { StyleSheet, Text, type TextProps } from 'react-native';
import { colors, textStyles, type TextVariant } from '@/theme';

type Props = TextProps & {
  variant?: TextVariant;
  color?: string;
  align?: 'left' | 'center' | 'right';
};

export function AppText({ variant = 'body', color, align, style, children, ...rest }: Props) {
  return (
    <Text
      style={[
        styles.base,
        textStyles[variant],
        color ? { color } : undefined,
        align ? { textAlign: align } : undefined,
        style,
      ]}
      {...rest}
    >
      {children}
    </Text>
  );
}

const styles = StyleSheet.create({
  base: {
    color: colors.textPrimary,
  },
});
