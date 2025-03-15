import React, { useEffect, useRef } from "react";
import { Animated, StyleSheet } from "react-native";

const ListeningBlob: React.FC = () => {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(scaleAnim, { toValue: 1.2, duration: 800, useNativeDriver: true }),
        Animated.timing(scaleAnim, { toValue: 1, duration: 800, useNativeDriver: true }),
      ])
    ).start();
  }, [scaleAnim]);

  return <Animated.View style={[styles.blob, { transform: [{ scale: scaleAnim }] }]} />;
};

const styles = StyleSheet.create({
  blob: {
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: "purple",
    opacity: 0.7,
  },
});

export default ListeningBlob;
