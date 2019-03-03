import React from 'react';
import {
  View
} from 'react-native';
import BreakdownRow from '../../components/BreakdownRow';
import MatchBreakdown from '../breakdowns/MatchBreakdown';
import breakdownStyle from '../../styles/breakdown';

export default class MatchBreakdown2019 extends MatchBreakdown {

  getSandstormBonusFor(breakdown, robotNumber) {
    if (breakdown["habLineRobot" + robotNumber] == "CrossedHabLineInSandstorm") {
      let result = breakdown["preMatchLevelRobot" + robotNumber]
      if (result.includes("HabLevel")) {
        return `Level ${result.substr(-1)}`
      }
    }
    return "--"
  }

  getHABClimbFor(breakdown, robotNumber) {
    let result = breakdown["endgameRobot" + robotNumber]
    if (result.includes("HabLevel")) {
      return `Level ${result.substr(-1)}`
    }
    return "--"
  }

  getCargoShipDataFor(breakdown) {
    var panelCount = 0
    var cargoCount = 0

    for (let i = 1; i <= 8; i++) {
      if (breakdown["bay" + i].includes("Panel")) {
        panelCount++
      }
      if (breakdown["bay" + i].includes("Cargo")) {
        cargoCount++
      }
    }
    return `${panelCount} / ${cargoCount}`
  }

  getRocketShipDataFor(breakdown, rocketLocation) {
    var locations = [
      "topLeftRocket",
      "topRightRocket",
      "midLeftRocket",
      "midRightRocket",
      "lowLeftRocket",
      "lowRightRocket"
    ]
    var panelCount = 0
    var cargoCount = 0
    locations.forEach(location => {
      if (breakdown[location + rocketLocation].includes("Panel")) {
        panelCount++
      }
      if (breakdown[location + rocketLocation].includes("Cargo")) {
        cargoCount++
      }
    });
    return `${panelCount} / ${cargoCount}`
  }

  render() {
    return (
      <View style={breakdownStyle.container}>

        <BreakdownRow data={["Teams", this.props.redTeams, this.props.blueTeams]} vertical={true} subtotal={true} />

        <BreakdownRow data={["Robot 1 Sandstorm Bonus",
          this.getSandstormBonusFor(this.props.redBreakdown, 1),
          this.getSandstormBonusFor(this.props.blueBreakdown, 1)]} />

        <BreakdownRow data={["Robot 2 Sandstorm Bonus",
          this.getSandstormBonusFor(this.props.redBreakdown, 2),
          this.getSandstormBonusFor(this.props.blueBreakdown, 2)]} />

        <BreakdownRow data={["Robot 3 Sandstorm Bonus",
          this.getSandstormBonusFor(this.props.redBreakdown, 3),
          this.getSandstormBonusFor(this.props.blueBreakdown, 3)]} />

        <BreakdownRow data={["Total Sandstorm Bonus",
          this.props.redBreakdown.sandStormBonusPoints,
          this.props.blueBreakdown.sandStormBonusPoints]} total={true} />

        <BreakdownRow data={["Cargo Ship: # Hatch Panels / # Cargo",
          this.getCargoShipDataFor(this.props.redBreakdown),
          this.getCargoShipDataFor(this.props.blueBreakdown)]} />

        <BreakdownRow data={["Rocket 1: # Hatch Panels / # Cargo",
          this.getRocketShipDataFor(this.props.redBreakdown, "Near"),
          this.getRocketShipDataFor(this.props.blueBreakdown, "Near")]} />

        <BreakdownRow data={["Rocket 2: # Hatch Panels / # Cargo",
          this.getRocketShipDataFor(this.props.redBreakdown, "Far"),
          this.getRocketShipDataFor(this.props.blueBreakdown, "Far")]} />

        <BreakdownRow data={["Total Points: Hatch Panels / Cargo",
          `${this.props.redBreakdown.hatchPanelPoints} / ${this.props.redBreakdown.cargoPoints}`,
          `${this.props.blueBreakdown.hatchPanelPoints} / ${this.props.blueBreakdown.cargoPoints}`]} subtotal={true} />

        <BreakdownRow data={["Robot 1 HAB Climb",
          this.getHABClimbFor(this.props.redBreakdown, 1),
          this.getHABClimbFor(this.props.blueBreakdown, 1)]} />

        <BreakdownRow data={["Robot 2 HAB Climb",
          this.getHABClimbFor(this.props.redBreakdown, 2),
          this.getHABClimbFor(this.props.blueBreakdown, 2)]} />

        <BreakdownRow data={["Robot 3 HAB Climb",
          this.getHABClimbFor(this.props.redBreakdown, 3),
          this.getHABClimbFor(this.props.blueBreakdown, 3)]} />

        <BreakdownRow data={["HAB Climb Points",
          this.props.redBreakdown.habClimbPoints,
          this.props.blueBreakdown.habClimbPoints]} subtotal={true} />

        <BreakdownRow data={["Total Teleop",
          this.props.redBreakdown.teleopPoints,
          this.props.blueBreakdown.teleopPoints]} total={true} />

        <BreakdownRow data={["Complete Rocket",
          this.props.redBreakdown.completeRocketRankingPoint ? this.checkImage() : this.xImage(),
          this.props.blueBreakdown.completeRocketRankingPoint ? this.checkImage() : this.xImage()]} />

        <BreakdownRow data={["HAB Docking",
          this.props.redBreakdown.habDockingRankingPoint ? this.checkImage() : this.xImage(),
          this.props.blueBreakdown.habDockingRankingPoint ? this.checkImage() : this.xImage()]} />

        <BreakdownRow data={["Fouls",
          ["+", this.props.redBreakdown.foulPoints],
          ["+", this.props.blueBreakdown.foulPoints]]} />

        <BreakdownRow data={["Adjustments",
          this.props.redBreakdown.adjustPoints,
          this.props.blueBreakdown.adjustPoints]} />

        <BreakdownRow data={["Total Score",
          this.props.redBreakdown.totalPoints,
          this.props.blueBreakdown.totalPoints]} total={true} />

        {this.props.compLevel == "qm" ? <BreakdownRow data={["Ranking Points",
          ["+", this.props.redBreakdown.rp, " RP"],
          ["+", this.props.blueBreakdown.rp, " RP"]]} /> : null}

      </View>
    );
  }
}
