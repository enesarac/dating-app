import React from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  View,
  type ViewStyle,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { colors, layout } from '@/theme';

type Props = {
  children: React.ReactNode;
  scrollable?: boolean;
  style?: ViewStyle;
  contentContainerStyle?: ViewStyle;
  edges?: ('top' | 'bottom' | 'left' | 'right')[];
  avoidKeyboard?: boolean;
  testID?: string;
};

export function Screen({
  children,
  scrollable = false,
  style,
  contentContainerStyle,
  edges = ['top', 'bottom'],
  avoidKeyboard = false,
  testID,
}: Props) {
  const inner = scrollable ? (
    <ScrollView
      contentContainerStyle={[styles.scrollContent, contentContainerStyle]}
      keyboardShouldPersistTaps="handled"
      showsVerticalScrollIndicator={false}
    >
      {children}
    </ScrollView>
  ) : (
    <View style={[styles.flex, contentContainerStyle]}>{children}</View>
  );

  const content = avoidKeyboard ? (
    <KeyboardAvoidingView
      style={styles.flex}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      {inner}
    </KeyboardAvoidingView>
  ) : (
    inner
  );

  return (
    <SafeAreaView style={[styles.container, style]} edges={edges} testID={testID}>
      {content}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.bgBase,
  },
  flex: {
    flex: 1,
    paddingHorizontal: layout.screenHorizontalPadding,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: layout.screenHorizontalPadding,
  },
});
