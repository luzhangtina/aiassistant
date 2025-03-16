import React, { useRef, useEffect } from 'react';
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

const MicrophoneButton: React.FC<MicrophoneButtonProps> = ({ isEnabled, onPress }) => {
  const { width } = useWindowDimensions();
  const buttonSize = Math.min(60, Math.max(40, width * 0.13));
  const rippleSize = buttonSize * 1.4;
  
  // Animation values for the three ripple circles
  const rippleAnim1 = useRef(new Animated.Value(0)).current;
  const rippleAnim2 = useRef(new Animated.Value(0)).current;
  const rippleAnim3 = useRef(new Animated.Value(0)).current;
  
  // Colors based on enabled state
  const buttonColor = isEnabled ? '#8A2BE2' : '#90EE90'; // Purple when enabled, Green when disabled
  const rippleColor = isEnabled ? 'rgba(138, 43, 226, 0.3)' : 'rgba(144, 238, 144, 0.3)';
  
  // Trigger ripple animation when pressed
  const triggerRippleAnimation = () => {
    // Reset animations
    rippleAnim1.setValue(0);
    rippleAnim2.setValue(0);
    rippleAnim3.setValue(0);
    
    // Create staggered ripple effect
    Animated.stagger(150, [
      Animated.timing(rippleAnim1, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
      Animated.timing(rippleAnim2, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
      Animated.timing(rippleAnim3, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
    ]).start();
  };
  
  // Handle press event
  const handlePress = () => {
    if (isEnabled) {
      triggerRippleAnimation();
      onPress();
    }
  };
  
  // Automatically start ripple animation when enabled
  useEffect(() => {
    if (isEnabled) {
      // Start a continuous ripple animation when enabled
      const animateRipples = () => {
        Animated.stagger(300, [
          Animated.timing(rippleAnim1, {
            toValue: 1,
            duration: 2000,
            useNativeDriver: true,
          }),
          Animated.timing(rippleAnim2, {
            toValue: 1,
            duration: 2000,
            useNativeDriver: true,
          }),
          Animated.timing(rippleAnim3, {
            toValue: 1,
            duration: 2000,
            useNativeDriver: true,
          }),
        ]).start(() => {
          // Reset animations and restart
          rippleAnim1.setValue(0);
          rippleAnim2.setValue(0);
          rippleAnim3.setValue(0);
          animateRipples();
        });
      };
      
      animateRipples();
    } else {
      // Stop animations when disabled
      rippleAnim1.setValue(0);
      rippleAnim2.setValue(0);
      rippleAnim3.setValue(0);
    }
    
    return () => {
      // Clean up animations on unmount
      rippleAnim1.stopAnimation();
      rippleAnim2.stopAnimation();
      rippleAnim3.stopAnimation();
    };
  }, [isEnabled]);
  
  // Scale and opacity animations for ripples
  const ripple1Style = {
    transform: [
      {
        scale: rippleAnim1.interpolate({
          inputRange: [0, 1],
          outputRange: [1, 1.5]
        })
      }
    ],
    opacity: rippleAnim1.interpolate({
      inputRange: [0, 1],
      outputRange: [0.5, 0]
    })
  };
  
  const ripple2Style = {
    transform: [
      {
        scale: rippleAnim2.interpolate({
          inputRange: [0, 1],
          outputRange: [1, 1.75]
        })
      }
    ],
    opacity: rippleAnim2.interpolate({
      inputRange: [0, 1],
      outputRange: [0.4, 0]
    })
  };
  
  const ripple3Style = {
    transform: [
      {
        scale: rippleAnim3.interpolate({
          inputRange: [0, 1],
          outputRange: [1, 2]
        })
      }
    ],
    opacity: rippleAnim3.interpolate({
      inputRange: [0, 1],
      outputRange: [0.3, 0]
    })
  };

  return (
    <View style={styles.microphoneContainer}>
      <TouchableOpacity
        style={styles.touchableArea}
        onPress={handlePress}
        disabled={!isEnabled}
        activeOpacity={0.8}
      >
        {/* Outermost ripple */}
        <Animated.View
          style={[
            styles.rippleCircle,
            {
              width: rippleSize * 1.4,
              height: rippleSize * 1.4,
              borderRadius: rippleSize * 1.4 / 2,
              backgroundColor: rippleColor,
            },
            ripple3Style
          ]}
        />
        
        {/* Middle ripple */}
        <Animated.View
          style={[
            styles.rippleCircle,
            {
              width: rippleSize * 1.2,
              height: rippleSize * 1.2,
              borderRadius: rippleSize * 1.2 / 2,
              backgroundColor: rippleColor,
            },
            ripple2Style
          ]}
        />
        
        {/* Innermost ripple */}
        <Animated.View
          style={[
            styles.rippleCircle,
            {
              width: rippleSize,
              height: rippleSize,
              borderRadius: rippleSize / 2,
              backgroundColor: rippleColor,
            },
            ripple1Style
          ]}
        >
          {/* Button */}
          <View
            style={[
              styles.microphoneButton,
              { 
                width: buttonSize, 
                height: buttonSize, 
                borderRadius: buttonSize / 2,
                backgroundColor: buttonColor,
              },
            ]}
          >
            <MaterialIcons name="mic" size={buttonSize * 0.48} color="#FFF" />
          </View>
        </Animated.View>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  microphoneContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  touchableArea: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  rippleCircle: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
  },
  microphoneButton: {
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
});

export default MicrophoneButton;