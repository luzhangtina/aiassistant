import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import React, { useEffect, useState } from 'react';
import 'react-native-reanimated';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Audio } from 'expo-av';

import { useColorScheme } from '@/hooks/useColorScheme';

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const [loaded] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
  });
  const [permissionGranted, setPermissionGranted] = useState(false);
  const [permissionDenied, setPermissionDenied] = useState(false);

  useEffect(() => {
    if (loaded) {
      // Function to check permission and proceed
      async function checkPermission() {
        const storedPermission = await AsyncStorage.getItem('microphonePermission');
        console.log("storedPermission", storedPermission)
        if (storedPermission == null) {
          const { status } = await Audio.requestPermissionsAsync();
          if (status === 'granted') {
            setPermissionGranted(true);
            await AsyncStorage.setItem('microphonePermission', 'granted');
            SplashScreen.hideAsync();
          } else {
            setPermissionDenied(true);
            await AsyncStorage.setItem('microphonePermission', 'denied');
          }
        } else if (storedPermission === 'denied') {
          setPermissionDenied(true);
        } else {
          setPermissionGranted(true);
          SplashScreen.hideAsync();
        } 
      }

      checkPermission();
    }
  }, [loaded]);

  if (!loaded) {
    return null;
  }

  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      <Stack>
        <Stack.Screen name="index" options={{ headerShown: false }} />
        <Stack.Screen name="+not-found" options={{ headerShown: false }} />
      </Stack>
      <StatusBar style="auto" />
    </ThemeProvider>
  );
}
