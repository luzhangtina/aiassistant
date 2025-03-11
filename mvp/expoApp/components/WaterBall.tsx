import { useEffect, useRef } from 'react';
import { Animated, View, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

interface WaterBallProps {
  factor: number; // Factor for ball size and opacity
  isAnimating: boolean; // Controls animation start/stop
}

export default function WaterBall({ factor, isAnimating }: WaterBallProps) {
  const ballSize = useRef(new Animated.Value(100)).current;
  const ballOpacity = useRef(new Animated.Value(0.7)).current;
  const gradientRotation = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (isAnimating) {
      Animated.loop(
        Animated.timing(gradientRotation, {
          toValue: 1,
          duration: 15000,
          useNativeDriver: false,
        })
      ).start();
    } else {
      gradientRotation.setValue(0);
    }
  }, [isAnimating]);

  useEffect(() => {
    let targetSize = 100 + factor * 150;
    let opacity = 0.5 + factor * 0.3;
    if (!isAnimating) {
        targetSize = 100;
        opacity = 0.7;
    }

    Animated.parallel([
      Animated.spring(ballSize, {
        toValue: targetSize,
        friction: 6,
        tension: 100,
        useNativeDriver: false,
      }),
      Animated.timing(ballOpacity, {
        toValue: opacity,
        duration: 200,
        useNativeDriver: false,
      })
    ]).start();
  }, [factor, isAnimating]);

  const spin = gradientRotation.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg']
  });

  return (
    <Animated.View
    style={[styles.waterBallContainer, {
        width: ballSize,
        height: ballSize,
        opacity: ballOpacity,
        borderRadius: Animated.divide(ballSize, 2),
        transform: [{ rotate: spin }],
    }]}
    >
    <LinearGradient
        colors={['#4FA4FF', '#6A82FB', '#67E8F9', '#05DAFA']}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.gradientOuter}
    />
    <LinearGradient
        colors={['rgba(73, 215, 255, 0.6)', 'rgba(147, 231, 254, 0.4)', 'rgba(105, 156, 255, 0.8)']}
        start={{ x: 0.2, y: 0.2 }}
        end={{ x: 0.8, y: 0.8 }}
        style={styles.gradientInner}
    />
    <View style={styles.highlight} />
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  waterBallContainer: {
    overflow: 'hidden',
    backgroundColor: 'transparent',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
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
