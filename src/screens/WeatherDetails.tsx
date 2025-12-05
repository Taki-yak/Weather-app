import React from "react";
import { VStack, Text, Center } from "native-base";

export default function WeatherDetails({ route }: any) {
  const { city } = route.params;
  return (
    <Center flex={1} bg="white">
      <VStack p={5} space={3}>
        <Text fontSize="xl" fontWeight="bold">Weather details for city code:</Text>
        <Text fontSize="3xl" color="blue.500">{city}</Text>
      </VStack>
    </Center>
  );
}
