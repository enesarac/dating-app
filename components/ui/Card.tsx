import React from 'react';
import {
  StyleSheet,
  TouchableOpacity,
  type TouchableOpacityProps,
  View,
  type ViewStyle,
} from 'react-native';
import { colors, layout, radius, shadows, spacing } from '@/theme';

type Props = {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: TouchableOpacityProps['onPress'];
  accessibilityLabel?: string;
  shadow?: boolean;
  padding?: number;
};

export function Card({
  children,
  style,
  onPress,
  accessibilityLabel,
  shadow = true,
  padding = layout.cardPadding,
}: Props) {
  const containerStyle = [
    styles.card,
    shadow ? shadows.card : undefined,
    { padding },
    style,
  ];

  if (onPress) {
    return (
      <TouchableOpacity
        activeOpacity={0.85}
        onPress={onPress}
        accessibilityRole="button"
        accessibilityLabel={accessibilityLabel}
        hitSlop={{ top: 4, bottom: 4, left: 4, right: 4 }}
        style={containerStyle}
      >
        {children}
      </TouchableOpacity>
    );
  }

  return <View style={containerStyle}>{children}</View>;
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.bgElevated,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: colors.borderDefault,
    gap: spacing[3],
  },
});
