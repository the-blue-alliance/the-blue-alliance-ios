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
        <View style={[styles.box, !this.props.total && styles.lightRed, (this.props.total || this.props.subtotal) && styles.red, !this.props.vertical && styles.row]}>
          {this.renderRow(this.props.data[1], this.props.total)}
        </View>
        <View style={[styles.box, this.props.total && styles.grey, this.props.subtotal && styles.grey]}>
          {this.renderRow(this.props.data[0], this.props.total)}
        </View>
        <View style={[styles.box, !this.props.total && styles.lightBlue, (this.props.total || this.props.subtotal) && styles.blue, !this.props.vertical && styles.row]}>
          {this.renderRow(this.props.data[2], this.props.total)}
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
      return <Image source={require('./img/ic_check_circle.png')} />
    } else if (teleopEngaged) {
      return <Image source={require('./img/ic_check.png')} />
    }
  }
  bonusCommon(value, bonus) {
    if (value == true) {
      return (
        <View style={{alignItems: 'center', flexDirection: 'row'}}>
          <Image source={require('./img/ic_check.png')} />
          <Text>(+ {bonus})</Text>
        </View>
      );
    } else {
      return <Image source={require('./img/ic_clear.png')} />
    }
  }
  checkImage() {
    return (
      <Image source={require('./img/ic_check.png')} />
    );
  }
  upArrow() {
    return (
      <Image source={require('./img/ic_keyboard_arrow_up.png')} />
    );
  }
  downArrow() {
    return (
      <Image source={require('./img/ic_keyboard_arrow_down.png')} />
    );
  }
  render() {
    return (
      <View style={styles.container}>
        
        <TBABreakdownRow data={["Teams", this.props.redTeams, this.props.blueTeams]} vertical={true} subtotal={true} />

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

        {this.props.compLevel == "qm" ? <TBABreakdownRow data={["Ranking Points",
                                ["+", this.props.redBreakdown.tba_rpEarned, " RP"],
                                ["+", this.props.blueBreakdown.tba_rpEarned, " RP"]]}/> : null}

      </View>
    );
  }
}

class TBAMatchBreakdown2016 extends React.Component {
  defenseName(defense) {
    if (defense == "A_ChevalDeFrise") {
      return "Cheval De Frise"
    } else if (defense == "A_Portcullis") {
      return "Portcullis"
    } else if (defense == "B_Ramparts") {
      return "Ramparts"
    } else if (defense == "B_Moat") {
      return "Moat"
    } else if (defense == "C_SallyPort") {
      return "Sally Port"
    } else if (defense == "C_Drawbridge") {
      return "Drawbridge"
    } else if (defense == "D_RoughTerrain") {
      return "Rough Terrain"
    } else if (defense == "D_RockWall") {
      return "Rock Wall"
    } else {
      return "Unknown"
    }
  }
  defenseCrossing(defense, crossingCount) {
      var defenseName = ""
      if (defense == "Low Bar") {
        defenseName = defense
      } else {
        defenseName = this.defenseName(defense)
      }
      return (
        <View>
          <Text style={{fontStyle: 'italic'}}>{defenseName}</Text>
          <Text>{crossingCount}x Cross</Text>
        </View>
      );
  }
  checkOrClear(value) {
    if (value == true) {
      return <Image source={require('./img/ic_check.png')} />
    } else {
      return <Image source={require('./img/ic_clear.png')} />
    }
  }
  render() {
    return (
      <View style={styles.container}>

        <TBABreakdownRow data={["Teams", this.props.redTeams, this.props.blueTeams]} vertical={true} subtotal={true} />

        <TBABreakdownRow data={["Auto Boulder Points",
                                this.props.redBreakdown.autoBoulderPoints,
                                this.props.blueBreakdown.autoBoulderPoints]}/>

        <TBABreakdownRow data={["Auto Reach Points",
                                this.props.redBreakdown.autoReachPoints,
                                this.props.blueBreakdown.autoReachPoints]}/>

        <TBABreakdownRow data={["Auto Crossing Points",
                                this.props.redBreakdown.autoCrossingPoints,
                                this.props.blueBreakdown.autoCrossingPoints]}/>

        <TBABreakdownRow data={["Total Auto",
                                this.props.redBreakdown.autoPoints,
                                this.props.blueBreakdown.autoPoints]} total={true}/>

        <TBABreakdownRow data={["Defense 1",
                                this.defenseCrossing("Low Bar", this.props.redBreakdown.position1crossings),
                                this.defenseCrossing("Low Bar", this.props.blueBreakdown.position1crossings)]}/>

        <TBABreakdownRow data={["Defense 2",
                                this.defenseCrossing(this.props.redBreakdown.position2, this.props.redBreakdown.position2crossings),
                                this.defenseCrossing(this.props.blueBreakdown.position2, this.props.blueBreakdown.position2crossings)]}/>

        <TBABreakdownRow data={["Defense 3 (Audience)",
                                this.defenseCrossing(this.props.redBreakdown.position3, this.props.redBreakdown.position3crossings),
                                this.defenseCrossing(this.props.blueBreakdown.position3, this.props.blueBreakdown.position3crossings)]}/>

        <TBABreakdownRow data={["Defense 4",
                                this.defenseCrossing(this.props.redBreakdown.position4, this.props.redBreakdown.position4crossings),
                                this.defenseCrossing(this.props.blueBreakdown.position4, this.props.blueBreakdown.position4crossings)]}/>

        <TBABreakdownRow data={["Defense 5",
                                this.defenseCrossing(this.props.redBreakdown.position5, this.props.redBreakdown.position5crossings),
                                this.defenseCrossing(this.props.blueBreakdown.position5, this.props.blueBreakdown.position5crossings)]}/>

        <TBABreakdownRow data={["Teleop Crossing Points",
                                this.props.redBreakdown.teleopCrossingPoints,
                                this.props.blueBreakdown.teleopCrossingPoints]} subtotal={true}/>

        <TBABreakdownRow data={["Teleop Boulders High",
                                this.props.redBreakdown.teleopBouldersHigh,
                                this.props.blueBreakdown.teleopBouldersHigh]}/>

        <TBABreakdownRow data={["Teleop Boulders Low",
                                this.props.redBreakdown.teleopBouldersLow,
                                this.props.blueBreakdown.teleopBouldersLow]}/>

        <TBABreakdownRow data={["Total Telop Boulder",
                                this.props.redBreakdown.teleopBoulderPoints,
                                this.props.blueBreakdown.teleopBoulderPoints]} subtotal={true}/>

        <TBABreakdownRow data={["Tower Challenge Points",
                                this.props.redBreakdown.teleopChallengePoints,
                                this.props.blueBreakdown.teleopChallengePoints]}/>

        <TBABreakdownRow data={["Tower Scale Points",
                                this.props.redBreakdown.teleopScalePoints,
                                this.props.blueBreakdown.teleopScalePoints]}/>

        <TBABreakdownRow data={["Total Teleop",
                                this.props.redBreakdown.teleopPoints,
                                this.props.blueBreakdown.teleopPoints]} total={true}/>

        <TBABreakdownRow data={["Defenses Breached",
                                this.checkOrClear(this.props.redBreakdown.teleopDefensesBreached),
                                this.checkOrClear(this.props.blueBreakdown.teleopDefensesBreached)]}/>

        <TBABreakdownRow data={["Tower Captured",
                                this.checkOrClear(this.props.redBreakdown.teleopTowerCaptured),
                                this.checkOrClear(this.props.blueBreakdown.teleopTowerCaptured)]}/>

        <TBABreakdownRow data={["Fouls",
                                ["+", this.props.redBreakdown.foulPoints],
                                ["+", this.props.blueBreakdown.foulPoints]]}/>

        <TBABreakdownRow data={["Adjustments",
                                this.props.redBreakdown.adjustPoints,
                                this.props.blueBreakdown.adjustPoints]}/>

        <TBABreakdownRow data={["Total Score",
                                this.props.redBreakdown.totalPoints,
                                this.props.blueBreakdown.totalPoints]} total={true}/>

        {this.props.compLevel == "qm" ? <TBABreakdownRow data={["Ranking Points",
                                ["+", this.props.redBreakdown.tba_rpEarned, " RP"],
                                ["+", this.props.blueBreakdown.tba_rpEarned, " RP"]]}/> : null}

      </View>
    );
  }
}

const ROBOT_SET_POINTS = 4;
const TOTE_SET_POINTS = 6;
const CONTAINER_SET_POINTS = 8;
const TOTE_STACK_POINTS = 20;
const COOP_SET_POINTS = 20;
const COOP_STACK_POINTS = 40;

class TBAMatchBreakdown2015 extends React.Component {
  foulPoints(value) {
    if (value == 0) {
      return <Text>{value}</Text>
    } else {
      return <Text>- {value}</Text>
    }
  }
  pointsCommon(value, points) {
    if (value == true) {
      return <Text>{points}</Text>
    } else {
      return <Text>0</Text>
    }
  }
  render() {
    return (
      <View style={styles.container}>

        <TBABreakdownRow data={["Teams", this.props.redTeams, this.props.blueTeams]} vertical={true} subtotal={true} />

        <TBABreakdownRow data={["Robot Set",
                                this.pointsCommon(this.props.redBreakdown.robot_set, ROBOT_SET_POINTS),
                                this.pointsCommon(this.props.blueBreakdown.robot_set, ROBOT_SET_POINTS)]}/>
        
        <TBABreakdownRow data={["Container Set",
                                this.pointsCommon(this.props.redBreakdown.container_set, CONTAINER_SET_POINTS),
                                this.pointsCommon(this.props.blueBreakdown.container_set, CONTAINER_SET_POINTS)]}/>
        
        <TBABreakdownRow data={["Tote Set",
                                this.pointsCommon(this.props.redBreakdown.tote_set, TOTE_SET_POINTS),
                                this.pointsCommon(this.props.blueBreakdown.tote_set, TOTE_SET_POINTS)]}/>

        <TBABreakdownRow data={["Tote Stack",
                                this.pointsCommon(this.props.redBreakdown.tote_stack, TOTE_STACK_POINTS),
                                this.pointsCommon(this.props.blueBreakdown.tote_stack, TOTE_STACK_POINTS)]}/>

        <TBABreakdownRow data={["Total Auto",
                                this.props.redBreakdown.auto_points,
                                this.props.blueBreakdown.auto_points]} total={true}/>

        <TBABreakdownRow data={["Tote Points",
                                this.props.redBreakdown.tote_points,
                                this.props.blueBreakdown.tote_points]}/>

        <TBABreakdownRow data={["Container Points",
                                this.props.redBreakdown.container_points,
                                this.props.blueBreakdown.container_points]}/>

        <TBABreakdownRow data={["Litter Points",
                                this.props.redBreakdown.litter_points,
                                this.props.blueBreakdown.litter_points]}/>

        <TBABreakdownRow data={["Total Teleop",
                                this.props.redBreakdown.teleop_points,
                                this.props.blueBreakdown.teleop_points]} total={true}/>

        <TBABreakdownRow data={["Coopertition",
                                this.props.redBreakdown.coopertition_points,
                                this.props.blueBreakdown.coopertition_points]}/>

        <TBABreakdownRow data={["Fouls",
                                ["-", this.props.redBreakdown.foul_points],
                                ["-", this.props.blueBreakdown.foul_points]]}/>

        <TBABreakdownRow data={["Adjustments",
                                this.props.redBreakdown.adjust_points,
                                this.props.blueBreakdown.adjust_points]}/>

        <TBABreakdownRow data={["Total Score",
                                this.props.redBreakdown.total_points,
                                this.props.blueBreakdown.total_points]} total={true}/>

      </View>
    );
  }
}

// Module name
AppRegistry.registerComponent('TBAMatchBreakdown2017', () => TBAMatchBreakdown2017);
AppRegistry.registerComponent('TBAMatchBreakdown2016', () => TBAMatchBreakdown2016);
AppRegistry.registerComponent('TBAMatchBreakdown2015', () => TBAMatchBreakdown2015);
