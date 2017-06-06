import React from 'react';
import {
    Platform,
    Text,
    TouchableHighlight,
    View
} from 'react-native';
import table from '../styles/table';

/**
 * Renders the right type of Touchable for the list item, based on platform.
 */
const Touchable = ({onPress, children}) => {
  const child = React.Children.only(children);
  if (Platform.OS === 'android') {
    return (
      <TouchableNativeFeedback onPress={onPress}>
        {child}
      </TouchableNativeFeedback>
    );
  } else {
    return (
      <TouchableHighlight onPress={onPress} underlayColor="#ddd">
        {child}
      </TouchableHighlight>
    );
  }
}

export default class InsightRow extends React.Component {
  render() {
    return (
      <Touchable onPress={this.props.onPress}>
        <View style={table.item}>
          <Text style={table.itemTitleLabel} >{this.props.title}</Text>
          <Text>Quals: {this.props.qual}</Text>
          <Text>Playoffs: {this.props.playoff}</Text>
        </View>
      </Touchable>
    );
  }
}
