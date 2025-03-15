import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import React, { useEffect, useState, useRef } from 'react';
import 'react-native-reanimated';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { AudioModule } from 'expo-audio';
import { Image, Animated } from 'react-native';

import { useColorScheme } from '@/hooks/useColorScheme';

import config from '@/config';

import { InitialResponse } from '@/types/SharedTypes';

// Prevent auto-hide until we finish animations
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const [loaded] = useFonts({
    SpaceMono: require('@/assets/fonts/SpaceMono-Regular.ttf'),
  });

  const [isReady, setIsReady] = useState(false);
  const [initialResponse, setInitialResponse] = useState<InitialResponse | null>(null);
  const fadeAnim = useRef(new Animated.Value(1)).current;

  const animationRef = useRef<Animated.CompositeAnimation | null>(null);

  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync().then(() => {
        animateSplashLogo();
      });

      checkPermissionAndLoadingInitData();
    }
  }, [loaded]);

  useEffect(() => {
    if (isReady && animationRef.current) {
      animationRef.current.stop();
    }
  }, [isReady]);

  async function checkPermissionAndLoadingInitData() {
    const storedPermission = await AsyncStorage.getItem('recordingPermission');

    if (storedPermission == null) {
      const status = await AudioModule.requestRecordingPermissionsAsync();
      if (status.granted) {
        await AsyncStorage.setItem('recordingPermission', 'granted');
        await fetchInitialResponse();
      } else {
        await AsyncStorage.setItem('recordingPermission', 'denied');
      }
    } else if (storedPermission === 'granted') {
      await fetchInitialResponse();
    } 
  }

  const fetchInitialResponse = async () => {
    try {
      const response = await fetch(`${config.apiUrl}/init`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          clientId: config.clientId,
          name: config.name,
        }),
      });
      const data = await response.json();
      console.log("fetched init data from server: ", data.currentQuestion)
      setInitialResponse({
        numberOfTotalQuestions: data.numberOfTotalQuestions,
        questions: data.questions,
        currentNumberOfQuestion: data.currentNumberOfQuestion,
        progress: data.progress,
        currentQuestion: data.currentQuestion,
        audioBase64: data.audioBase64
      });
      setIsReady(true);
    } catch (error) {
      console.error('Error fetching initial response:', error);
    }
  };

  const animateSplashLogo = () => {
    // Store the animation reference so we can stop it later
    animationRef.current = Animated.loop(
      Animated.sequence([
        Animated.timing(fadeAnim, {
          toValue: 0.3,
          duration: 1000,
          useNativeDriver: true,
        }),
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }),
      ])
    );
    
    // Start the animation
    animationRef.current.start();
  };

  const splashLogo = (
    <Animated.View
      style={{
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        opacity: fadeAnim, // Apply animation
      }}
    >
      <Image
        source={require('@/assets/images/splash-icon.png')}
        style={{ width: 150, height: 150 }}
      />
    </Animated.View>
  );

  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      {isReady && 
        <Stack>
          <Stack.Screen name="index" options={{ headerShown: false }} initialParams={{ initialResponse: JSON.stringify(initialResponse) }}/>
          <Stack.Screen name="+not-found" options={{ headerShown: false }} />
        </Stack>
      }
      {!isReady && splashLogo}
      <StatusBar style="auto" />
    </ThemeProvider>
  );
}
