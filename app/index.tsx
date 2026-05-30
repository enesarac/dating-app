import { StyleSheet, View } from 'react-native';
import { colors, spacing } from '@/theme';
import { AppText } from '@/components/ui';

export default function HomeScreen() {
  return (
    <View style={styles.container}>
      <AppText variant="title1" align="center">
        pair
      </AppText>
      <AppText variant="body" color={colors.textSecondary} align="center">
        kurulum tamamlandı
      </AppText>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bgBase,
    gap: spacing[3],
  },
});
