import { QuestionList } from '@/types/SharedTypes';
import React, { useState, useEffect } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView, 
} from 'react-native';

interface QuestionListScrollViewProps {
  currentNumberOfQuestion: number
  questions: QuestionList[];
}

const QuestionListScrollView: React.FC<QuestionListScrollViewProps> = ({ currentNumberOfQuestion, questions }) => {
  return (
    <ScrollView style={styles.questionsContainer}>
        {questions.map((question) => (
            <View key={question.number} style={styles.questionItem}>
            <Text style={styles.questionNumber}>{question.number}.</Text>
            <Text 
                style={[
                styles.questionText,
                question.number === currentNumberOfQuestion ? styles.activeQuestion : {}
                ]}
            >
                {question.question}
            </Text>
            </View>
        ))}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  questionsContainer: {
    flex: 1,
    paddingHorizontal: 20,
    marginTop: 20,
  },
  questionItem: {
    flexDirection: 'row',
    marginBottom: 20,
  },
  questionNumber: {
    color: '#888',
    fontSize: 15,
    marginRight: 5,
    width: 20,
  },
  questionText: {
    color: '#888',
    fontSize: 15,
    flex: 1,
  },
  activeQuestion: {
    color: '#fff',
    fontWeight: 'bold',
  },
});

export default QuestionListScrollView;