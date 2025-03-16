import React, { useEffect, useState } from 'react';
import { 
  StyleSheet, 
  View, 
  SafeAreaView, 
  StatusBar,
} from 'react-native';
import { useLocalSearchParams } from 'expo-router';

import { Audio } from 'expo-av';
import { useAudioRecorder, RecordingPresets } from 'expo-audio';
import * as FileSystem from 'expo-file-system';

import ProgressBar from "@/components/ProgressBar";
import WaveformVisualization from "@/components/WaveformVisualization";
import QuestionDisplay from "@/components/QuestionDisplay";
import FooterActions from '@/components/FooterActions';
import QuestionListScrollView from "@/components/QuestionListScrollView"

import { QuestionList } from '@/types/SharedTypes';
import { useWebSocket } from '@/hooks/useWebSocket';
import config from '@/config';

type StaticQuestionData = {
  numberOfTotalQuestions: number;
  questions: QuestionList[];
};

type DynamicQuestionData = {
  currentNumberOfQuestion: number;
  progress: number;
  currentQuestion: string;
};

// Main App Component
const SurveyScreen: React.FC = () => {
  const { initialResponse } = useLocalSearchParams<{ initialResponse?: string }>();
  const [staticQuestionData, setStaticQuestionData] = useState<StaticQuestionData | null>(null);
  const [dynamicQuestionData, setDynamicQuestionData] = useState<DynamicQuestionData | null>(null);
  const [audio, setAudio] = useState<Audio.Sound | null>(null);
  const [canPressRecordButton, setCanPressRecordButton] = useState(false);
  const [isRecordButtonPressed, setIsRecordButtonPressed] = useState(false);
  const [viewQuestion, setSetViewQuestion] = useState(true);
  const audioRecorder = useAudioRecorder(RecordingPresets.HIGH_QUALITY);

  const handleSocketMessage = (event: WebSocketMessageEvent) => {
    const data = JSON.parse(event.data);
    
    const isSurveyCompleted = data.isSurveyCompleted;
    setDynamicQuestionData({
      "currentNumberOfQuestion": data.currentNumberOfQuestion,
      "currentQuestion": data.currentQuestion,
      "progress": data.progress
    });

    if (data.audioBase64) {
      playAudio(data.audioBase64, isSurveyCompleted);
    }
  };

  const { sendMessage, closeConnection } = useWebSocket(config.wsUrl, handleSocketMessage);

  const playAudio = async (base64: string, isLastMessage: boolean = false) => {
    try {
      // Unload previous audio if exists
      if (audio) {
        await audio.unloadAsync();
      }

      console.log("base64 is: ", base64.substring(0, 50) + "..."); // Log just a preview
      const audioUri = `data:audio/wav;base64,${base64}`;
      const { sound } = await Audio.Sound.createAsync(
        { uri: audioUri },
        { shouldPlay: true },
        ( status ) => {
          if (status.isLoaded && status.didJustFinish && (!isLastMessage)) {
            setIsRecordButtonPressed(false);
            setCanPressRecordButton(true);
          }
        }
      );
      setAudio(sound);
    } catch (error) {
      console.error('Error playing audio:', error);
    }
  };

  const startRecording = async () => {
    console.log('recording started');
    await audioRecorder.prepareToRecordAsync();
    audioRecorder.record();
  };

  const stopRecording = async () => {   
    console.log('Stopping recording..');
    audioRecorder.stop();

    if (!audioRecorder.uri) {
      return;
    }
    
    console.log('Recorded uri is ', audioRecorder.uri);

    // Read the file as base64
    const base64Audio = await FileSystem.readAsStringAsync(audioRecorder.uri, {
      encoding: FileSystem.EncodingType.Base64,
    });

    const message = {
      clientId: config.clientId,
      name: config.name,
      audioBase64: base64Audio
    }

    sendMessage(message); 
  };

  useEffect(() => {
    if (initialResponse) {
      const result = JSON.parse(initialResponse);
      setStaticQuestionData({
        numberOfTotalQuestions: result.numberOfTotalQuestions,
        questions: result.questions,
      });

      setDynamicQuestionData({
        currentNumberOfQuestion: result.currentNumberOfQuestion,
        progress: result.progress,
        currentQuestion: result.currentQuestion,
      });

      playAudio(result.audioBase64);
    }
  }, [initialResponse]);

  const toggleRecording = () => {
    if (isRecordButtonPressed) {
      stopRecording(); // Stop if already recording
      setCanPressRecordButton(false);
    } else {
      setIsRecordButtonPressed(true);
      startRecording(); // Start if not recording
    }
  };

  const toggleViewQuestion = () => {
    setSetViewQuestion((prev) => (!prev));
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      
      {dynamicQuestionData && staticQuestionData && (
        <ProgressBar
          current={dynamicQuestionData.currentNumberOfQuestion}
          total={staticQuestionData.numberOfTotalQuestions}
          percentage={dynamicQuestionData.progress}
          viewQuestion={viewQuestion}
          onPress={toggleViewQuestion}
        />
      )}
      
      <View style={styles.contentContainer}>
        {viewQuestion && (
          <>
            <WaveformVisualization />
            {dynamicQuestionData && (
              <QuestionDisplay question={dynamicQuestionData.currentQuestion} />
            )}
          </>
        )}
        {!viewQuestion && dynamicQuestionData && staticQuestionData && (
          <QuestionListScrollView
            currentNumberOfQuestion={dynamicQuestionData.currentNumberOfQuestion}
            questions={staticQuestionData?.questions}/>
        )}
        <FooterActions 
          enableRecording={canPressRecordButton} 
          onToggleRecording={toggleRecording} 
        />
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
});

export default SurveyScreen;
