import React, { useState } from "react";
import { VStack, Text, Input, Button, Center } from "native-base";
import { updatePrefs } from "../weatherApi";

export default function Settings() {
  const [city, setCity] = useState("");

  const update = async () => {
    await updatePrefs(1, city);
    alert("Settings updated using PUT ✅");
  };

  return (
    <Center flex={1} bg="white" p={5}>
      <VStack w="100%" maxW="350px" space={3}>
        <Text fontSize="2xl" fontWeight="bold" textAlign="center">Settings</Text>
        <Input placeholder="Preferred city code" onChangeText={setCity} />
        <Button onPress={update}>Update Preferences (PUT)</Button>
      </VStack>
    </Center>
  );
}
