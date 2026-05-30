import { Image, type ImageStyle } from 'expo-image';
import React from 'react';
import { StyleSheet, View, type ViewStyle } from 'react-native';
import { colors, typography } from '@/theme';
import { AppText } from './AppText';

type Size = 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';

type Props = {
  uri?: string | null;
  initials?: string;
  size?: Size;
  accessibilityLabel?: string;
};

const sizeMap: Record<Size, number> = {
  xs: 24,
  sm: 32,
  md: 44,
  lg: 56,
  xl: 72,
  '2xl': 96,
};

const fontSizeMap: Record<Size, number> = {
  xs: 10,
  sm: 13,
  md: 17,
  lg: 22,
  xl: 28,
  '2xl': 36,
};

export function Avatar({ uri, initials, size = 'md', accessibilityLabel }: Props) {
  const dim = sizeMap[size];
  const fontSize = fontSizeMap[size];

  const circleViewStyle: ViewStyle = { width: dim, height: dim, borderRadius: dim / 2 };
  const circleImageStyle: ImageStyle = { width: dim, height: dim, borderRadius: dim / 2 };

  if (uri) {
    return (
      <Image
        source={{ uri }}
        style={[styles.image, circleImageStyle]}
        contentFit="cover"
        accessibilityLabel={accessibilityLabel}
        accessibilityRole="image"
      />
    );
  }

  return (
    <View style={[styles.placeholder, circleViewStyle]} accessibilityLabel={accessibilityLabel}>
      {initials ? (
        <AppText
          style={{
            fontSize,
            fontWeight: typography.weight.semibold,
            color: colors.textOnBrand,
          }}
        >
          {initials.slice(0, 2).toUpperCase()}
        </AppText>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  image: {
    overflow: 'hidden',
  },
  placeholder: {
    backgroundColor: colors.brand,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
});
