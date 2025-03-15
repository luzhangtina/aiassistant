import React from 'react';
import { 
  StyleSheet, 
  View, 
  useWindowDimensions
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

const WaveformVisualization: React.FC = () => {
  const { height } = useWindowDimensions();
  // Adjust waveform height based on device height
  const waveformHeight = Math.max(80, Math.min(120, height * 0.15));
  
  return (
    <View style={[styles.waveformContainer, { height: waveformHeight }]}>
      <LinearGradient
        colors={['#9370DB', '#FFFFFF', '#90EE90']}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 0 }}
        style={[styles.waveform, { height: waveformHeight }]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  waveformContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: '10%',
    },
  waveform: {
    width: '100%',
    borderRadius: 10,
  }
});

export default WaveformVisualization;