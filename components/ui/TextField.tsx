import React, { forwardRef, useState } from 'react';
import { StyleSheet, TextInput, type TextInputProps, View, type ViewStyle } from 'react-native';
import { colors, radius, spacing, typography } from '@/theme';
import { AppText } from './AppText';

type Props = TextInputProps & {
  label?: string;
  error?: string;
  hint?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  containerStyle?: ViewStyle;
};

export const TextField = forwardRef<TextInput, Props>(function TextField(
  { label, error, hint, leftIcon, rightIcon, containerStyle, style, onFocus, onBlur, ...rest },
  ref,
) {
  const [focused, setFocused] = useState(false);
  const hasError = Boolean(error);

  return (
    <View style={[styles.container, containerStyle]}>
      {label ? (
        <AppText variant="subhead" style={styles.label}>
          {label}
        </AppText>
      ) : null}

      <View style={[styles.inputRow, focused && styles.focused, hasError && styles.errorBorder]}>
        {leftIcon ? <View style={styles.iconLeft}>{leftIcon}</View> : null}
        <TextInput
          ref={ref}
          style={[
            styles.input,
            leftIcon ? styles.inputWithLeft : undefined,
            rightIcon ? styles.inputWithRight : undefined,
            style,
          ]}
          placeholderTextColor={colors.textDisabled}
          accessibilityLabel={label}
          onFocus={(e) => {
            setFocused(true);
            onFocus?.(e);
          }}
          onBlur={(e) => {
            setFocused(false);
            onBlur?.(e);
          }}
          {...rest}
        />
        {rightIcon ? <View style={styles.iconRight}>{rightIcon}</View> : null}
      </View>

      {hasError ? (
        <AppText variant="caption1" color={colors.error} style={styles.hint}>
          {error}
        </AppText>
      ) : hint ? (
        <AppText variant="caption1" color={colors.textSecondary} style={styles.hint}>
          {hint}
        </AppText>
      ) : null}
    </View>
  );
});

const styles = StyleSheet.create({
  container: {
    gap: spacing[1],
  },
  label: {
    color: colors.textSecondary,
    fontWeight: typography.weight.medium,
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1.5,
    borderColor: colors.borderDefault,
    borderRadius: radius.md,
    backgroundColor: colors.bgBase,
    minHeight: 48,
  },
  focused: {
    borderColor: colors.borderFocus,
  },
  errorBorder: {
    borderColor: colors.error,
  },
  input: {
    flex: 1,
    paddingHorizontal: spacing[3],
    paddingVertical: spacing[2.5],
    fontSize: typography.size.md,
    color: colors.textPrimary,
  },
  inputWithLeft: {
    paddingLeft: spacing[1],
  },
  inputWithRight: {
    paddingRight: spacing[1],
  },
  iconLeft: {
    paddingLeft: spacing[3],
  },
  iconRight: {
    paddingRight: spacing[3],
  },
  hint: {
    marginTop: spacing[0.5],
  },
});
