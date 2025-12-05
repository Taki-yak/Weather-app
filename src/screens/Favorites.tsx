import React, { useState } from "react";
import { VStack, Text, Input, Button, Center } from "native-base";
import { saveFavorite } from "../weatherApi";

export default function Favorites() {
  const [city, setCity] = useState("");

  const store = async () => {
    await saveFavorite(city);
    alert("Saved via POST ✅");
  };

  return (
    <Center flex={1} bg="white" p={5}>
      <VStack w="100%" maxW="350px" space={3}>
        <Text fontSize="2xl" fontWeight="bold" textAlign="center">Favorite Cities</Text>
        <Input placeholder="Enter city code" onChangeText={setCity} />
        <Button onPress={store}>Save Favorite (POST)</Button>
      </VStack>
    </Center>
  );
}
