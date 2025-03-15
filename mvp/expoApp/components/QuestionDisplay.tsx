import React from 'react';
import { 
  StyleSheet, 
  View, 
  Text, 
  useWindowDimensions
} from 'react-native';

interface QuestionDisplayProps {
  question: string | undefined;
}

const QuestionDisplay: React.FC<QuestionDisplayProps> = ({ question }) => {
  if (question === undefined) return null;
  
  const { width, height } = useWindowDimensions();
  // Adjust font size based on screen dimensions for better readability
  const dynamicFontSize = Math.min(24, Math.max(18, width * 0.06));
  
  return (
    <View style={[styles.questionContainer, { minHeight: height * 0.2 }]}>
      <Text style={[styles.questionText, { fontSize: dynamicFontSize }]}>
        {question}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  questionContainer: {
    marginTop: '5%',
    marginBottom: '10%',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 10,
  },
  questionText: {
    color: '#FFF',
    fontWeight: 'bold',
    textAlign: 'center',
    lineHeight: 32,
  },
});

export default QuestionDisplay;