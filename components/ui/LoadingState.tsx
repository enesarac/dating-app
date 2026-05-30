import React from 'react';
import { ActivityIndicator, StyleSheet, View, type ViewStyle } from 'react-native';
import { colors, spacing } from '@/theme';
import { AppText } from './AppText';

type Props = {
  message?: string;
  size?: 'small' | 'large';
  color?: string;
  style?: ViewStyle;
  fullScreen?: boolean;
};

export function LoadingState({
  message,
  size = 'large',
  color = colors.brand,
  style,
  fullScreen = true,
}: Props) {
  return (
    <View style={[fullScreen ? styles.fullScreen : styles.inline, style]}>
      <ActivityIndicator size={size} color={color} />
      {message ? (
        <AppText variant="body" color={colors.textSecondary} style={styles.message}>
          {message}
        </AppText>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  fullScreen: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing[3],
  },
  inline: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing[4],
    gap: spacing[2],
  },
  message: {
    marginTop: spacing[2],
  },
});
