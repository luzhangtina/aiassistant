import { StyleSheet, ScrollView, View } from 'react-native';
import React, { useEffect, useRef, useState } from 'react';
import { ThemedView } from '@/components/ThemedView';
import { useLocalSearchParams } from 'expo-router';
import { Audio, InterruptionModeIOS, InterruptionModeAndroid } from 'expo-av';
import WaterBall from '@/components/WaterBall';
import { ThemedText } from '@/components/ThemedText';

export default function HomeScreen() {
  const { initialResponse } = useLocalSearchParams<{ initialResponse?: string }>();
  const [audio, setAudio] = useState<Audio.Sound | null>(null);
  const [isAnimating, setIsAnimating] = useState(false);
  const [transcript, setTranscript] = useState<string | null>(null);
  // Mock speech level - in a real app, this would come from audio input
  const [speechLevel, setSpeechLevel] = useState(0);
  
  useEffect(() => {
    const setupAudio = async () => {
      try {
        await Audio.setAudioModeAsync({
          allowsRecordingIOS: false,
          interruptionModeIOS: InterruptionModeIOS.DoNotMix,
          playsInSilentModeIOS: true,
          interruptionModeAndroid: InterruptionModeAndroid.DoNotMix,
          shouldDuckAndroid: true,
          staysActiveInBackground: true,
          playThroughEarpieceAndroid: false
        });
        console.log("Audio mode set successfully");
      } catch (error) {
        console.error('Error setting audio mode:', error);
      }
    };
    
    setupAudio();
    
    // Cleanup function
    return () => {
      if (audio) {
        console.log("Unloading audio on component cleanup");
        audio.unloadAsync();
      }
    };
  }, []);

  useEffect(() => {
    if (initialResponse) {
      const parsedResponse = JSON.parse(initialResponse);
      console.log("transcript is: ", parsedResponse.transcript);
      setTranscript(parsedResponse.transcript);
      playInitialAudio(parsedResponse.audioBase64);
    }
  }, [initialResponse]);

  const playInitialAudio = async (base64: string) => {
    try {
      // Unload previous audio if exists
      if (audio) {
        await audio.unloadAsync();
      }

      console.log("base64 is: ", base64.substring(0, 50) + "..."); // Log just a preview
      const audioUri = `data:audio/wav;base64,${base64}`;
      const { sound } = await Audio.Sound.createAsync(
        { uri: audioUri },
        { shouldPlay: true },
        (status) => {
          if (status.isLoaded && status.didJustFinish) {
            setIsAnimating(true);
            setTranscript(null); // Hide transcript when audio finishes
          }
        }
      );
      setAudio(sound);
    } catch (error) {
      console.error('Error playing audio:', error);
    }
  };

  // Simulate changing speech levels for testing
  useEffect(() => {
    const interval = setInterval(() => {
      const newLevel = Math.random(); // Mocking speech level
      setSpeechLevel(newLevel);
    }, 500);
    return () => clearInterval(interval);
  }, []);

  return (
    <ThemedView style={styles.container}>
      {transcript && (
        <View style={styles.transcriptContainer}>
          <ScrollView style={styles.transcriptScroll}>
            <View style={styles.transcriptWrapper}>
              <ThemedText>{transcript}</ThemedText>
            </View>
        </ScrollView>
        </View>
      )}
      <View style={styles.ballContainer}>
        <WaterBall isAnimating={isAnimating} factor={speechLevel} />
      </View>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
  },
  transcriptContainer: {
    position: 'absolute',
    top: '15%',
    width: '80%',
    maxHeight: '50%', // Prevents it from taking up too much space
    alignItems: 'center',
    padding: 10,
  },
  transcriptScroll: {
    width: '100%',
  },
  transcriptWrapper: {
    width: '100%',
    alignItems: 'center', // Ensures text is centered inside ScrollView
  },
  ballContainer: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
    marginBottom: 60,
  },
});