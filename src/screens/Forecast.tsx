import React from "react";
import { VStack, Text, Center } from "native-base";

export default function Forecast() {
  return (
    <Center flex={1} bg="white">
      <VStack p={5}>
        <Text fontSize="2xl" fontWeight="bold">5 Day Forecast</Text>
        <Text mt={2}>This screen is required to make 8 screens ✅</Text>
      </VStack>
    </Center>
  );
}
