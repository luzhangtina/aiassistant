import React, { useEffect, useState, useRef } from 'react';
import { 
  StyleSheet, 
  View, 
  TouchableOpacity, 
  useWindowDimensions,
  Animated
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

interface MicrophoneButtonProps {
  isEnabled: boolean;
  onPress: () => void;
}

const MicrophoneButton: React.FC<MicrophoneButtonProps> = React.memo(({ isEnabled, onPress }) => {
  const { width } = useWindowDimensions();
  const buttonSize = Math.min(60, Math.max(40, width * 0.13));
  const rippleSize = buttonSize * 1.4;
  const buttonColor = isEnabled ? '#9370DB' : '#90EE90';
  const rippleColor = isEnabled ? 'rgba(170, 110, 226, 0.38)' : 'rgba(144, 238, 144, 0.3)';

  const rippleAnim = useRef(new Animated.Value(0)).current;
  const [isAnimating, setIsAnimating] = useState(false);

  const createRippleStyle = (scale: number, opacity: number) => ({
    transform: [{ scale: rippleAnim.interpolate({ inputRange: [0, 1], outputRange: [1, scale] }) }],
    opacity: rippleAnim.interpolate({ inputRange: [0, 1], outputRange: [opacity, 0] })
  });

  const handlePress = () => {
    if (isEnabled) {
      setIsAnimating(!isAnimating);
      onPress();
    }
  };

  useEffect(() => {
    if (isEnabled && isAnimating) {
      Animated.loop(
        Animated.timing(rippleAnim, {
          toValue: 1,
          duration: 2000,
          useNativeDriver: true,
        })
      ).start();
    } else {
      rippleAnim.stopAnimation();
      rippleAnim.setValue(0);
    }

    return () => rippleAnim.stopAnimation();
  }, [isEnabled, isAnimating]);

  return (
    <View style={styles.microphoneContainer}>
      <TouchableOpacity
        style={styles.touchableArea}
        onPress={isEnabled ? handlePress : undefined}
        disabled={!isEnabled}
        activeOpacity={isEnabled ? 1 : 0.25} 
      >
        {isEnabled && isAnimating && (
          <>
            <Animated.View
              style={[styles.rippleCircle, { width: rippleSize * 1.4, height: rippleSize * 1.4, borderRadius: rippleSize * 1.4 / 2, backgroundColor: rippleColor }, createRippleStyle(1.75, 0.3)]}
            />
            <Animated.View
              style={[styles.rippleCircle, { width: rippleSize * 1.2, height: rippleSize * 1.2, borderRadius: rippleSize * 1.2 / 2, backgroundColor: rippleColor }, createRippleStyle(1.5, 0.4)]}
            />
            <Animated.View
              style={[styles.rippleCircle, { width: rippleSize, height: rippleSize, borderRadius: rippleSize / 2, backgroundColor: rippleColor }, createRippleStyle(1.25, 0.5)]}
            />
          </>
        )}
        <View
          style={[styles.microphoneButton, { width: buttonSize, height: buttonSize, borderRadius: buttonSize / 2, backgroundColor: buttonColor, opacity: isEnabled ? 1 : 0.4 }]}
        >
          <MaterialIcons name="mic" size={buttonSize * 0.48} color="#FFF"/>
        </View>
      </TouchableOpacity>
    </View>
  );
});

const styles = StyleSheet.create({
  microphoneContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  touchableArea: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  microphoneButton: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  rippleCircle: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default MicrophoneButton;
