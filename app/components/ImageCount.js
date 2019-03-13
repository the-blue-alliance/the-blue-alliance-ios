import React from 'react';
import {
  Text,
  View
} from 'react-native';

export default class ImageCount extends React.Component {
  render() {
    return (
      <View style={{ flexDirection: 'row', alignItems: 'center', marginHorizontal: 4 }}>
        {this.props.image != null &&
          <View style={{paddingRight: 1}}>{this.props.image}</View>
        }
        {this.props.count != null &&
          <Text>{this.props.count}</Text>
        }
      </View>
    );
  }
}
