import { StyleSheet, ScrollView, View } from 'react-native';
import React, { useEffect, useRef, useState } from 'react';
import { ThemedView } from '@/components/ThemedView';
import { useLocalSearchParams } from 'expo-router';
import { Audio } from 'expo-av';
import Voice, {
  type SpeechResultsEvent,
  type SpeechErrorEvent,
} from '@react-native-voice/voice';
import * as FileSystem from 'expo-file-system';
import { useAudioRecorder, RecordingPresets } from 'expo-audio';

import WaterBall from '@/components/WaterBall';
import TranscriptDisplay from '@/components/TranscriptDisplay';
import { useWebSocket } from '@/hooks/useWebSocket';
import config from '@/config';

export default function HomeScreen() {
  const { initialResponse } = useLocalSearchParams<{ initialResponse?: string }>();
  const [audio, setAudio] = useState<Audio.Sound | null>(null);
  const [isAnimating, setIsAnimating] = useState(false);
  const [transcript, setTranscript] = useState<string | null>(null);
  // Mock speech level - in a real app, this would come from audio input
  const [recordingStatus, setRecordingStatus] = useState<"idle" | "init" | "stop" | "end">("idle");
  const audioRecorder = useAudioRecorder(RecordingPresets.HIGH_QUALITY);
  const [speechLevel, setSpeechLevel] = useState(0);

  const onSpeechEnd = (e: any) => {
    console.log('Voice recognizition detected speech end.');
    setRecordingStatus("stop");
  };

  const onSpeechError = (e: SpeechErrorEvent) => {
    console.log('onSpeechError: ', e);
  };

  const onSpeechResults = (e: SpeechResultsEvent) => {
    console.log( e.value && e.value?.length > 0 ? e.value : []);
  };

  const onSpeechVolumeChanged = (e: any) => {
    setSpeechLevel(e.value);
  };

  const handleSocketMessage = (event: WebSocketMessageEvent) => {
    const data = JSON.parse(event.data);
    
    if (data.transcript) {
      setTranscript(data.transcript);
    }
    
    if (data.audioBase64) {
      playInitialAudio(data.audioBase64);
    }

    if (data.isSurveyCompleted) {
      setRecordingStatus("end");
    }
  };

  const { sendMessage, closeConnection } = useWebSocket(config.wsUrl, handleSocketMessage);
  
  useEffect(() => {  
    // Cleanup function
    return () => {
      console.log("Unmounted the screen");
      if (audio) {
        console.log("Unloading audio on component cleanup");
        audio.unloadAsync();
      }
  
      cleanUpRecording();
      closeConnection();
    };
  }, []);

  useEffect(() => {
    if (initialResponse) {
      const parsedResponse = JSON.parse(initialResponse);
      console.log("transcript is: ", parsedResponse.transcript);
      setTranscript(parsedResponse.transcript);
      playInitialAudio(parsedResponse.audioBase64);
    }
  }, [initialResponse]);

  useEffect(() => {
    if (recordingStatus === "init") {
      startRecording();
    } else if (recordingStatus === "stop") {
      stopRecording();
    } else if (recordingStatus === "end") {
      cleanUpRecording();
    }
  }, [recordingStatus]);

  const playInitialAudio = async (base64: string) => {
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
          if (status.isLoaded && status.didJustFinish) {
            setTranscript(null); // Hide transcript when audio finishes
            setRecordingStatus("init");
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
    Voice.onSpeechEnd = onSpeechEnd;
    Voice.onSpeechError = onSpeechError;
    Voice.onSpeechResults = onSpeechResults;
    Voice.onSpeechVolumeChanged = onSpeechVolumeChanged;

    await Voice.start('en-US');
    
    await audioRecorder.prepareToRecordAsync();
    audioRecorder.record();
  };

  const stopRecording = async () => {   
    console.log('Stopping recording..');
    await Voice.stop();
    audioRecorder.stop();

    await processSpeechData();
  };

  const cleanUpRecording = async () => {
    Voice.destroy().then(Voice.removeAllListeners);
    audioRecorder.stop();
  }

  const processSpeechData = async () => {
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

  return (
    <ThemedView style={styles.container}>
      <View style={styles.transcriptContainer}>
        <TranscriptDisplay transcript={transcript} />
      </View>
      <View style={styles.ballContainer}>
        <WaterBall isAnimating={isAnimating} factor={speechLevel} />
      </View>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
  },
  transcriptContainer: {
    position: 'absolute',
    top: '15%',
    width: '80%',
    maxHeight: '50%', // Prevents it from taking up too much space
    alignItems: 'center',
    padding: 10,
  },
  ballContainer: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
    marginBottom: 60,
  },
});