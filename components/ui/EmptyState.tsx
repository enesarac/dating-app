import React from 'react';
import { StyleSheet, View, type ViewStyle } from 'react-native';
import { colors, spacing } from '@/theme';
import { AppText } from './AppText';
import { Button } from './Button';

type Props = {
  icon?: React.ReactNode;
  title: string;
  description?: string;
  action?: {
    label: string;
    onPress: () => void;
  };
  style?: ViewStyle;
};

export function EmptyState({ icon, title, description, action, style }: Props) {
  return (
    <View style={[styles.container, style]}>
      {icon ? <View style={styles.iconWrap}>{icon}</View> : null}
      <AppText variant="title3" align="center" style={styles.title}>
        {title}
      </AppText>
      {description ? (
        <AppText variant="body" color={colors.textSecondary} align="center">
          {description}
        </AppText>
      ) : null}
      {action ? (
        <Button
          label={action.label}
          onPress={action.onPress}
          variant="secondary"
          fullWidth={false}
          style={styles.actionButton}
        />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing[8],
    gap: spacing[3],
  },
  iconWrap: {
    marginBottom: spacing[2],
    opacity: 0.6,
  },
  title: {
    color: colors.textPrimary,
  },
  actionButton: {
    marginTop: spacing[2],
  },
});
