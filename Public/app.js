import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import { ChakraProvider, VStack, Container, Heading, Flex, Box } from "@chakra-ui/react";
import { BrowserRouter as Router, Route, Routes, Switch } from 'react-router-dom';

function SideBar() {
  return (
    <Box bg="green.500" w={200} h="100vh" p={4} color="white">
      Side Bar
    </Box>
  );
}


function TopBar() {
  return (
    <Box bg="blue.500" w="100%" p={4} color="white">
      Top Bar
    </Box>
  );
}


function MainContent() {
    
    // Remove this to get rid of popup on load
    useEffect( ()=> {
        alert("Vapor & ChakraUI page loaded");
    })
    
    return (
        <Box flex="1" p={4}>
          Main Content Area
        </Box>
    );
}

function MainLayout() {
  return (
    <Box>
      <TopBar />
      <Flex>
        <SideBar />
        <MainContent />
      </Flex>
    </Box>
  );
}

function App() {
    
    return (
        <Container maxW="container.xl" py={10}>
            <Routes>
                <Route path="/" element={<MainLayout />} >
                </Route>
            </Routes>
        </Container>
    );
}

const rootElement = document.getElementById("app");

const root = ReactDOM.createRoot(rootElement);
root.render(
  <ChakraProvider>
    <Router>
        <App />
    </Router>
  </ChakraProvider>
);
