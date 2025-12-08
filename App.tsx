import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";
import { Provider as PaperProvider } from "react-native-paper";
import 'react-native-reanimated';
import Home from "./src/screens/Home";
import Weather from "./src/screens/Weather";
import CameraScreen from "./src/screens/CameraScreen";

const Stack = createStackNavigator();

export default function App() {
  return (
    <PaperProvider>
      <NavigationContainer>
        <Stack.Navigator screenOptions={{ headerShown: true }}>
          <Stack.Screen name="Home" component={Home} />
          <Stack.Screen name="Weather" component={Weather} />
          <Stack.Screen name="Camera" component={CameraScreen} />
        </Stack.Navigator>
      </NavigationContainer>
    </PaperProvider>
  );
}
