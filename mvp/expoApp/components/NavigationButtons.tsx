import React from "react";
import { View, TouchableOpacity, StyleSheet } from "react-native";
import { FontAwesome } from "@expo/vector-icons";

type NavigationButtonsProps = {
  onBack: () => void;
  onClose: () => void;
};

const NavigationButtons: React.FC<NavigationButtonsProps> = ({ onBack, onClose }) => (
  <View style={styles.navContainer}>
    <TouchableOpacity onPress={onBack}>
      <FontAwesome name="chevron-left" size={24} color="#fff" />
    </TouchableOpacity>
    <TouchableOpacity onPress={onClose}>
      <FontAwesome name="times" size={24} color="#fff" />
    </TouchableOpacity>
  </View>
);

const styles = StyleSheet.create({
  navContainer: { flexDirection: "row", justifyContent: "space-between", padding: 20 },
});

export default NavigationButtons;
