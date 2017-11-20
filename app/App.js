import React from 'react';
import { StackNavigator } from 'react-navigation';
import HomeScreen from './screens/HomeScreen';

const Navigator = StackNavigator({
  Home: { screen: HomeScreen }
});

const App = () => (
  <Navigator />
);

export default App;
