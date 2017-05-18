'use strict';

import React from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';

class TBATeamAtEventStatus extends React.Component {
  render() {
    return (
      <View>
        <Text>
          Team @ Event View Controller
        </Text>
      </View>
    );
  }
}

// Module name
AppRegistry.registerComponent('TBATeamAtEventStatus', () => TBATeamAtEventStatus);
