import React from "react";
import { VStack, Input, Button, Text, Center } from "native-base";

export default function Login({ navigation }: any) {
  return (
    <Center flex={1} bg="blue.50">
      <VStack space={4} p={5} w="90%" maxW="300px" bg="white" shadow={2} borderRadius="md">
        <Text fontSize="xl" fontWeight="bold" textAlign="center">Weather Student App</Text>
        <Input placeholder="Enter Email" />
        <Input placeholder="Enter Password" type="password" />
        <Button onPress={() => navigation.navigate("AppMenu")}>Login</Button>
        <Button variant="outline" onPress={() => navigation.navigate("Register")}>Create Account</Button>
      </VStack>
    </Center>
  );
}
