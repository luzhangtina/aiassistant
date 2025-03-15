export type QuestionList = {
  number: number;
  question: string;
};

export type InitialResponse = {
  numberOfTotalQuestions: number;
  questions: QuestionList[];
  currentNumberOfQuestion: number;
  progress: number;
  currentQuestion: string;
  audioBase64: string;
};