import React from 'react';
import { 
  StyleSheet, 
  View, 
  SafeAreaView, 
  StatusBar,
} from 'react-native';

import ProgressBar from "@/components/ProgressBar";
import WaveformVisualization from "@/components/WaveformVisualization";
import QuestionDisplay from "@/components/QuestionDisplay";
import FooterActions from '@/components/FooterActions';

// Main App Component
const SurveyScreen: React.FC = () => {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      
      <ProgressBar current={6} total={24} percentage={25} />
      
      <View style={styles.contentContainer}>
        <WaveformVisualization />
        
        <QuestionDisplay 
          question="With regard to the Chair's leadership, which areas are currently strengths?"
        />
        
        <FooterActions />
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  contentContainer: {
    flex: 1,
    justifyContent: 'space-between',
    padding: 20,
  },
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

export default SurveyScreen;