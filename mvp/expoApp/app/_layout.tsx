import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import React, { useEffect, useState, useRef } from 'react';
import 'react-native-reanimated';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Audio } from 'expo-av';
import { Image, Animated } from 'react-native';

import { useColorScheme } from '@/hooks/useColorScheme';

// Prevent auto-hide until we finish animations
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const [loaded] = useFonts({
    SpaceMono: require('@/assets/fonts/SpaceMono-Regular.ttf'),
  });

  const [isReady, setIsReady] = useState(false);
  const fadeAnim = useRef(new Animated.Value(1)).current;

  const animationRef = useRef<Animated.CompositeAnimation | null>(null);

  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync().then(() => {
        animateSplashLogo();
      });

      checkPermission();
    }
  }, [loaded]);

  useEffect(() => {
    if (isReady && animationRef.current) {
      animationRef.current.stop();
    }
  }, [isReady]);

  async function checkPermission() {
    const storedPermission = await AsyncStorage.getItem('microphonePermission');

    if (storedPermission == null) {
      const { status } = await Audio.requestPermissionsAsync();
      if (status === 'granted') {
        await AsyncStorage.setItem('microphonePermission', 'granted');
        setIsReady(true);
      } else {
        await AsyncStorage.setItem('microphonePermission', 'denied');
      }
    } else if (storedPermission === 'granted') {
      setIsReady(true);
    } 
  }

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
          <Stack.Screen name="index" options={{ headerShown: false }} />
          <Stack.Screen name="+not-found" options={{ headerShown: false }} />
        </Stack>
      }
      {!isReady && splashLogo}
      <StatusBar style="auto" />
    </ThemeProvider>
  );
}
