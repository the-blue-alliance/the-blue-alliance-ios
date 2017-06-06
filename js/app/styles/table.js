'use strict';

import {
  StyleSheet,
} from 'react-native';

const table = StyleSheet.create({
  header: {
    height: 28,
    justifyContent: 'center',
    left: 20,
    borderBottomWidth: StyleSheet.hairlineWidth,
    backgroundColor: '#303F9F',
  },
  headerLabel: {
    fontSize: 14,
    color: 'white'
  },
  item: {
    justifyContent: 'center',
    paddingTop: 8,
    paddingBottom: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
    left: 20,
    borderBottomColor: '#ddd'
  },
  itemTitleLabel: {
    color: '#00000089',
    fontWeight: 'bold',
    fontSize: 12,
  }
});

export default table;
