import React, { useEffect, useState } from "react";
import { View, StyleSheet, ActivityIndicator } from "react-native";
import { Text, Button } from "react-native-paper";
import { fetchWeather } from "../api/weatherService";
export default function Weather({ route, navigation }: any) {
  const { city } = route.params;
  const [weather, setWeather] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchWeather();
  }, []);

  const fetchWeather = async () => {
    try {
      // Replace with your own API key
      const apiKey = "1d3ccbcdcabd2860ab75df7a6e2d0498";
      const response = await fetch(
        `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`
      );
      const data = await response.json();
      setWeather(data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <ActivityIndicator style={{ flex: 1 }} size="large" />;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Weather in {city}</Text>
      {weather?.main ? (
        <>
          <Text>Temperature: {weather.main.temp} °C</Text>
          <Text>Humidity: {weather.main.humidity} %</Text>
          <Text>Condition: {weather.weather[0].description}</Text>
        </>
      ) : (
        <Text>City not found ❌</Text>
      )}
      <Button onPress={() => navigation.goBack()} style={styles.button}>
        Back
      </Button>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", alignItems: "center", padding: 20 },
  title: { fontSize: 24, marginBottom: 20 },
  button: { marginTop: 20 },
});
