'use strict';

import React from 'react';
import ReactNative from 'react-native';
import {
  AppRegistry,
  StyleSheet,
  View
} from 'react-native';

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ddd',
    paddingBottom: 8,
    paddingTop: 8,
  },
  box: {
    justifyContent: 'center',
    alignItems: 'center',
    flex: 1,
    paddingBottom: 2,
    paddingTop: 2,
  },
  grey: {
    backgroundColor: '#ccc',
  },
  lightRed: {
    backgroundColor: '#ff000011',
  },
  red: {
    backgroundColor: '#ff000022',
  },
  lightBlue: {
    backgroundColor: '#0000ff11',
  },
  blue: {
    backgroundColor: '#0000ff22',
  },
  row: {
    flexDirection: 'row',
  },
  infoRow: {
    minHeight: 40,
    marginBottom: 2,
  },
  font: {
    fontSize: 12,
    textAlign: 'center'
  },
  imageSize: {
    width: 24,
    height: 24
  },
  total: {
    fontWeight: 'bold',
  },
});

const Text = ({ style, ...props }) => <ReactNative.Text style={[styles.font, style]} {...props} />;
const Image = ({ style, ...props }) => <ReactNative.Image style={[styles.imageSize, style]} {...props} />;

class TBABreakdownRow extends React.Component {
  renderRow(data, total) {
    if (!Array.isArray(data)) {
      data = [data]
    }
    return data.map(function(value, i) {
      if (typeof value == 'object') {
        return value
      }
      return <Text style={[total && styles.total]}>{value}</Text>
    });
  }
  render() {
    return (
      <View style={[styles.row, styles.infoRow]}>
        <View style={[styles.box, this.props.total && styles.red, !this.props.total && styles.lightRed, !this.props.vertical && styles.row]}>
          {this.renderRow(this.props.data[1])}
        </View>
        <View style={[styles.box, this.props.total && styles.grey, this.props.vertical && styles.grey]}>
          {this.renderRow(this.props.data[0], this.props.total)}
        </View>
        <View style={[styles.box, this.props.total && styles.blue, !this.props.total && styles.lightBlue, !this.props.vertical && styles.row]}>
          {this.renderRow(this.props.data[2])}
        </View>
      </View>
    );
  }
}

class TBAMatchBreakdown2017 extends React.Component {
  renderRotorView(json_data, rotor_number) {
    var autoEngaged = false
    if (rotor_number == 1 || rotor_number == 2) {
      autoEngaged = json_data["rotor" + rotor_number + "Auto"]
    }
    var teleopEngaged = json_data["rotor" + rotor_number + "Engaged"]
    
    if (autoEngaged) {
      return <Image source={require('./img/ic_check_circle_36pt.png')} />
    } else if (teleopEngaged) {
      return <Image source={require('./img/ic_check_36pt.png')} />
    }
  }
  bonusCommon(value, bonus) {
    if (value == true) {
      return (
        <View style={{alignItems: 'center', flexDirection: 'row'}}>
          <Image source={require('./img/ic_check_36pt.png')} />
          <Text>(+ {bonus})</Text>
        </View>
      );
    } else {
      return <Image source={require('./img/ic_clear_36pt.png')} />
    }
  }
  checkImage() {
    return (
      <Image source={require('./img/ic_check_36pt.png')} />
    );
  }
  upArrow() {
    return (
      <Image source={require('./img/ic_keyboard_arrow_up_36pt.png')} />
    );
  }
  downArrow() {
    return (
      <Image source={require('./img/ic_keyboard_arrow_down_36pt.png')} />
    );
  }
  render() {
    return (
      <View style={styles.container}>
        
        <TBABreakdownRow data={["Teams", this.props.redTeams, this.props.blueTeams]} vertical={true} />

        <TBABreakdownRow data={["Auto Mobility",
                                this.props.redBreakdown.autoMobilityPoints,
                                this.props.blueBreakdown.autoMobilityPoints]}/>

        <TBABreakdownRow data={["Auto Fuel",
                                [this.upArrow(), this.props.redBreakdown.autoFuelHigh, this.downArrow(), this.props.redBreakdown.autoFuelLow],
                                [this.upArrow(), this.props.blueBreakdown.autoFuelHigh, this.downArrow(), this.props.blueBreakdown.autoFuelLow]]}/>

        <TBABreakdownRow data={["Auto Pressure Points",
                                this.props.redBreakdown.autoFuelPoints,
                                this.props.blueBreakdown.autoFuelPoints]}/>

        <TBABreakdownRow data={["Auto Rotors",
                                [this.props.redBreakdown.rotor1Auto ? this.checkImage() : null, this.props.redBreakdown.rotor2Auto ? this.checkImage() : null],
                                [this.props.blueBreakdown.rotor1Auto ? this.checkImage() : null, this.props.blueBreakdown.rotor2Auto ? this.checkImage() : null]]}/>

        <TBABreakdownRow data={["Auto Rotor Points",
                                this.props.redBreakdown.autoRotorPoints,
                                this.props.blueBreakdown.autoRotorPoints]}/>

        <TBABreakdownRow data={["Total Auto",
                                this.props.redBreakdown.autoPoints,
                                this.props.blueBreakdown.autoPoints]} total={true}/>

        <TBABreakdownRow data={["Teleop Fuel",
                                [this.upArrow(), this.props.redBreakdown.teleopFuelHigh, this.downArrow(), this.props.redBreakdown.teleopFuelLow],
                                [this.upArrow(), this.props.blueBreakdown.teleopFuelHigh, this.downArrow(), this.props.blueBreakdown.teleopFuelLow]]}/>

        <TBABreakdownRow data={["Teleop Pressure Points",
                                this.props.redBreakdown.teleopFuelPoints,
                                this.props.blueBreakdown.teleopFuelPoints]}/>

        <TBABreakdownRow data={["Teleop Rotors",
                                [1, 2, 3, 4].map(rotor_number => this.renderRotorView(this.props.redBreakdown, rotor_number)),
                                [1, 2, 3, 4].map(rotor_number => this.renderRotorView(this.props.blueBreakdown, rotor_number))]}/>

        <TBABreakdownRow data={["Teleop Rotor Points",
                                this.props.redBreakdown.teleopRotorPoints,
                                this.props.blueBreakdown.teleopRotorPoints]}/>

        <TBABreakdownRow data={["Takeoff Points",
                                this.props.redBreakdown.teleopTakeoffPoints,
                                this.props.blueBreakdown.teleopTakeoffPoints]}/>

        <TBABreakdownRow data={["Total Teleop",
                                this.props.redBreakdown.teleopPoints,
                                this.props.blueBreakdown.teleopPoints]} total={true}/>

        <TBABreakdownRow data={["Pressure Reached",
                                this.bonusCommon(this.props.redBreakdown.kPaBonusPoints == 20, this.props.redBreakdown.kPaBonusPoints),
                                this.bonusCommon(this.props.blueBreakdown.kPaBonusPoints == 20, this.props.blueBreakdown.kPaBonusPoints)]}/>

        <TBABreakdownRow data={["All Rotors Engaged",
                                this.bonusCommon(this.props.redBreakdown.rotor1Engaged && this.props.redBreakdown.rotor2Engaged && this.props.redBreakdown.rotor3Engaged && this.props.redBreakdown.rotor4Engaged, this.props.redBreakdown.rotorBonusPoints),
                                this.bonusCommon(this.props.blueBreakdown.rotor1Engaged && this.props.blueBreakdown.rotor2Engaged && this.props.blueBreakdown.rotor3Engaged && this.props.blueBreakdown.rotor4Engaged, this.props.blueBreakdown.rotorBonusPoints)]}/>

        <TBABreakdownRow data={["Fouls",
                                ["+", this.props.redBreakdown.foulPoints],
                                ["+", this.props.blueBreakdown.foulPoints]]}/>

        <TBABreakdownRow data={["Adjustments",
                                this.props.redBreakdown.adjustPoints,
                                this.props.blueBreakdown.adjustPoints]}/>

        <TBABreakdownRow data={["Total Score",
                                this.props.redBreakdown.totalPoints,
                                this.props.blueBreakdown.totalPoints]} total={true}/>

      </View>
    );
  }
}

// Module name
AppRegistry.registerComponent('TBAMatchBreakdown2017', () => TBAMatchBreakdown2017);
