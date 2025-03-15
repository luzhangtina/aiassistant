import React from "react";
import { Text, StyleSheet } from "react-native";

type QuestionTextProps = {
  question: string;
};

const QuestionText: React.FC<QuestionTextProps> = ({ question }) => (
  <Text style={styles.questionText}>{question}</Text>
);

const styles = StyleSheet.create({
  questionText: {
    color: "#fff",
    fontSize: 20,
    textAlign: "center",
    marginVertical: 20,
  },
});

export default QuestionText;
