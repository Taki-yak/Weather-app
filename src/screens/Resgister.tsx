import React from "react";
import { VStack, Input, Button, Text, Center } from "native-base";

export default function Register({ navigation }: any) {
  return (
    <Center flex={1} bg="blue.50">
      <VStack space={4} p={5} w="90%" maxW="300px" bg="white" shadow={2} borderRadius="md">
        <Text fontSize="xl" fontWeight="bold" textAlign="center">Create Student Account</Text>
        <Input placeholder="Full Name" />
        <Input placeholder="Email" />
        <Input placeholder="Password" type="password" />
        <Button onPress={() => navigation.navigate("Login")}>Register</Button>
      </VStack>
    </Center>
  );
}
