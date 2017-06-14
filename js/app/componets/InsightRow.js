import React from 'react';
import {
    Text,
    View
} from 'react-native';
import table from '../styles/table';

export default class InsightRow extends React.Component {
  render() {
    return (
      <View style={table.item}>
        <Text style={table.itemTitleLabel} >{this.props.title}</Text>
        <Text>Quals: {this.props.qual}</Text>
        <Text>Playoffs: {this.props.playoff}</Text>
      </View>
    );
  }
}
