import React from 'react';
import { 
  StyleSheet, 
  View, 
  TouchableOpacity, 
  useWindowDimensions
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

  return (
    <View style={styles.microphoneContainer}>
        <TouchableOpacity
            style={[
                styles.microphoneRipple,
                {
                    width: rippleSize,
                    height: rippleSize,
                    borderRadius: rippleSize / 2,
                    opacity: isEnabled ? 1 : 0.5, // Dim the button when it's disabled
                }
            ]}
            onPress={isEnabled ? onPress : undefined} // Only trigger onPress if enabled
            disabled={!isEnabled} // Disable interaction if not enabled
        >
        <View
          style={[
            styles.microphoneButton,
            { width: buttonSize, height: buttonSize, borderRadius: buttonSize / 2 },
          ]}
        >
          <MaterialIcons name="mic" size={buttonSize * 0.48} color="#FFF" />
        </View>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  microphoneContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  microphoneRipple: {
    backgroundColor: 'rgba(144, 238, 144, 0.3)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  microphoneButton: {
    backgroundColor: '#90EE90',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default MicrophoneButton;
