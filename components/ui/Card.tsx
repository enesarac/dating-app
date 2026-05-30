import React from 'react';
import {
  StyleSheet,
  TouchableOpacity,
  type TouchableOpacityProps,
  View,
  type ViewStyle,
} from 'react-native';
import { colors, layout, radius, shadows, spacing, type RadiusToken } from '@/theme';

type Props = {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: TouchableOpacityProps['onPress'];
  accessibilityLabel?: string;
  shadow?: boolean;
  padding?: number;
  /** Override corner radius. Default is 'lg' (16). Profile cards use 'xl' or '2xl'. */
  borderRadius?: RadiusToken;
};

export function Card({
  children,
  style,
  onPress,
  accessibilityLabel,
  shadow = true,
  padding = layout.cardPadding,
  borderRadius: borderRadiusToken = 'lg',
}: Props) {
  const containerStyle = [
    styles.card,
    shadow ? shadows.card : undefined,
    { padding, borderRadius: radius[borderRadiusToken] },
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
    borderWidth: 1,
    borderColor: colors.borderDefault,
    gap: spacing[3],
  },
});
