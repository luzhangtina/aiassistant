import { StyleSheet, Animated, View, Dimensions } from 'react-native';
import React, { useEffect, useRef, useState } from 'react';
import { ThemedView } from '@/components/ThemedView';
import { LinearGradient } from 'expo-linear-gradient';
import { useLocalSearchParams } from 'expo-router';
import { Audio } from 'expo-av';

export default function HomeScreen() {
  const { initialResponse } = useLocalSearchParams<{ initialResponse?: string }>();
  const [audio, setAudio] = useState<Audio.Sound | null>(null);

    // Mock speech level - in a real app, this would come from audio input
  const [speechLevel, setSpeechLevel] = useState(0);
  const ballSize = useRef(new Animated.Value(100)).current;
  const ballOpacity = useRef(new Animated.Value(0.7)).current;
  const gradientRotation = useRef(new Animated.Value(0)).current;
  
  useEffect(() => {
    if (initialResponse) {
      const parsedResponse = JSON.parse(initialResponse);
      console.log("transcript is: ", parsedResponse.transcript);
      playInitialAudio(parsedResponse.audioBase64);
    }
  }, [initialResponse]);

  const playInitialAudio = async (base64: string) => {
    try {
      const audioUri = `data:audio/wav;base64,${base64}`;
      const { sound } = await Audio.Sound.createAsync(
        { uri: audioUri }
      )
      setAudio(sound);
      await sound.playAsync();
    } catch (error) {
      console.error('Error playing audio:', error);
    }
  };

  // Convert rotation value to interpolated string for transform
  const spin = gradientRotation.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg']
  });
  
  // Simulate changing speech levels for testing
  useEffect(() => {
    const interval = setInterval(() => {
      // Generate random value between 0 and 1
      const newLevel = Math.random();
      setSpeechLevel(newLevel);
    }, 500);
    
    // Start continuous rotation animation
    Animated.loop(
      Animated.timing(gradientRotation, {
        toValue: 1,
        duration: 15000,
        useNativeDriver: false,
      })
    ).start();
    
    return () => clearInterval(interval);
  }, []);
  
  // Animate ball size based on speech level
  useEffect(() => {
    // Base size + expansion based on speech level
    const targetSize = 100 + (speechLevel * 150);
    
    Animated.parallel([
      Animated.spring(ballSize, {
        toValue: targetSize,
        friction: 6,
        tension: 100,
        useNativeDriver: false,
      }),
      Animated.timing(ballOpacity, {
        toValue: 0.5 + (speechLevel * 0.3),
        duration: 200,
        useNativeDriver: false,
      })
    ]).start();
  }, [speechLevel]);

  return (
    <ThemedView style={styles.container}>
      <View style={styles.ballContainer}>
        <Animated.View
          style={[
            styles.waterBallContainer,
            {
              width: ballSize,
              height: ballSize,
              opacity: ballOpacity,
              borderRadius: Animated.divide(ballSize, 2),
              transform: [{ rotate: spin }],
            }
          ]}
        >
          {/* Outer gradient for aurora effect */}
          <LinearGradient
            colors={['#4FA4FF', '#6A82FB', '#67E8F9', '#05DAFA']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={styles.gradientOuter}
          />
          
          {/* Inner gradient for depth */}
          <LinearGradient
            colors={['rgba(73, 215, 255, 0.6)', 'rgba(147, 231, 254, 0.4)', 'rgba(105, 156, 255, 0.8)']}
            start={{ x: 0.2, y: 0.2 }}
            end={{ x: 0.8, y: 0.8 }}
            style={styles.gradientInner}
          />
          
          {/* Highlight for water effect */}
          <View style={styles.highlight} />
        </Animated.View>
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
  ballContainer: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
    marginBottom: 60,
  },
  waterBallContainer: {
    overflow: 'hidden',
    backgroundColor: 'transparent',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 5,
  },
  gradientOuter: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderRadius: 999,
  },
  gradientInner: {
    position: 'absolute',
    top: '15%',
    left: '15%',
    right: '15%',
    bottom: '15%',
    borderRadius: 999,
    opacity: 0.7,
  },
  highlight: {
    position: 'absolute',
    top: '20%',
    left: '25%',
    width: '25%',
    height: '25%',
    borderRadius: 999,
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
    transform: [{ scaleX: 1.5 }],
  },
});