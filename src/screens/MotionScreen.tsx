import React, { useState, useEffect } from 'react';
import { Accelerometer } from 'expo-sensors';
import { VStack, Text, Center } from "native-base";

export default function MotionScreen() {
  const [data, setData] = useState({x:0, y:0, z:0});

  useEffect(() => {
    const sub = Accelerometer.addListener(setData);
    return () => sub.remove();
  }, []);

  return (
    <Center flex={1} bg="white">
      <VStack p={5} space={2}>
        <Text fontSize="xl" fontWeight="bold">Accelerometer Data ✅</Text>
        <Text>X: {data.x.toFixed(2)}</Text>
        <Text>Y: {data.y.toFixed(2)}</Text>
        <Text>Z: {data.z.toFixed(2)}</Text>
      </VStack>
    </Center>
  );
}
