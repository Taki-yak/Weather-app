import React, { useState } from "react";
import { View, StyleSheet } from "react-native";
import { TextInput, Button, Text } from "react-native-paper";

export default function Home({ navigation }: any) {
  const [city, setCity] = useState("");

  const goToWeather = () => {
    if (city.trim() === "") return;
    navigation.navigate("Weather", { city });
  };

  const goToCamera = () => {
    navigation.navigate("Camera");
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Weather App 🌤️</Text>

      <TextInput
        label="Enter city"
        value={city}
        onChangeText={setCity}
        style={styles.input}
      />

      <Button mode="contained" onPress={goToWeather} style={styles.button}>
        Get Weather
      </Button>

      <Button mode="outlined" onPress={goToCamera} style={styles.button}>
        Open Camera
      </Button>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", padding: 20 },
  title: { fontSize: 28, marginBottom: 20, textAlign: "center" },
  input: { marginBottom: 20 },
  button: { marginTop: 10 },
});
