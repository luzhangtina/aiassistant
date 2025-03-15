import React from 'react';
import { 
  StyleSheet, 
  View, 
  TouchableOpacity, 
  useWindowDimensions
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

import MicrophoneButton from '@/components/MicrophoneButton';

interface FooterActionsProps {
    enableRecording: boolean;
    onToggleRecording: () => void;
}

// Footer Actions Component
const FooterActions: React.FC<FooterActionsProps> = ({ enableRecording, onToggleRecording }) => {
  const { width } = useWindowDimensions();
  // Make buttons proportional to screen width
  const buttonSize = Math.min(50, Math.max(36, width * 0.1));
  
  return (
    <View style={styles.footerContainer}>
      <TouchableOpacity style={[
        styles.footerButton, 
        { 
          width: buttonSize, 
          height: buttonSize, 
          borderRadius: buttonSize / 2 
        }
      ]}>
        <MaterialIcons 
          name="keyboard" 
          size={buttonSize * 0.5} 
          color="#FFF" 
        />
      </TouchableOpacity>
      
      <MicrophoneButton 
        isEnabled={enableRecording}
        onPress={onToggleRecording}
      />
      
      <TouchableOpacity style={[
        styles.footerButton, 
        { 
          width: buttonSize, 
          height: buttonSize, 
          borderRadius: buttonSize / 2 
        }
      ]}>
        <MaterialIcons 
          name="close" 
          size={buttonSize * 0.5} 
          color="#FFF" 
        />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  footerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingBottom: 20,
    marginTop: 'auto',
  },
  footerButton: {
    backgroundColor: '#333',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default FooterActions;