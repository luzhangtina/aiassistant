import React from 'react';
import { StyleSheet, ScrollView, View } from 'react-native';
import { ThemedText } from '@/components/ThemedText';

interface TranscriptDisplayProps {
  transcript: string | null;
}

const TranscriptDisplay: React.FC<TranscriptDisplayProps> = ({ transcript }) => {
  if (!transcript) return null; // Don't render if no transcript

  return (
    <ScrollView style={styles.transcriptScroll}>
      <View style={styles.transcriptWrapper}>
        <ThemedText>{transcript}</ThemedText>
      </View>
    </ScrollView>
  );
};

export default TranscriptDisplay;

const styles = StyleSheet.create({
  transcriptScroll: {
    width: '100%',
  },
  transcriptWrapper: {
    width: '100%',
    alignItems: 'center', // Ensures text is centered inside ScrollView
  }
});
