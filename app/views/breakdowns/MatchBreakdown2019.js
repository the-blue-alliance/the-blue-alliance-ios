import React from 'react';
import ReactNative from 'react-native';
import {
  View,
  Text
} from 'react-native';
import BreakdownRow from '../../components/BreakdownRow';
import images from '../../config/images';
import ImageCount from '../../components/ImageCount';
import MatchBreakdown from '../breakdowns/MatchBreakdown';
import breakdownStyle from '../../styles/breakdown';
import {safeRender} from '../../helpers/safeRender'

// Override our Image and Text to have specific sizes
const Image = ({ style, ...props }) => <ReactNative.Image style={[breakdownStyle.imageSize, style]} {...props} />;

export default class MatchBreakdown2019 extends MatchBreakdown {

  nullHatchPanelImage() {
    return (
      <Image source={images[2019].hatchPanel} style={{ tintColor: '#616161' }} />
    );
  }

  hatchPanelImage() {
    return (
      <Image source={images[2019].hatchPanel} style={{ tintColor: '#ffeb3b' }} />
    );
  }

  cargoImage() {
    return (
      <Image source={images[2019].cargo} style={{ tintColor: '#ff6d00' }} />
    );
  }

  getSandstormBonusFor(breakdown, robotNumber) {
    if (breakdown["habLineRobot" + robotNumber] == "CrossedHabLineInSandstorm") {
      let result = breakdown["preMatchLevelRobot" + robotNumber]
      if (result.includes("HabLevel")) {
        let level = result.substr(-1);
        let climbPoints = [3, 6];
        return `Level ${level} (+${climbPoints[level - 1]})`
      }
    }
    return this.xImage()
  }

  getHABClimbFor(breakdown, robotNumber) {
    let result = breakdown["endgameRobot" + robotNumber]
    if (result.includes("HabLevel")) {
      let level = result.substr(-1);
      let climbPoints = [3, 6, 12];
      return `Level ${level} (+${climbPoints[level-1]})`
    }
    return this.xImage()
  }

  getCargoShipDataFor(breakdown) {
    var nullPanelCount = 0
    var panelCount = 0
    var cargoCount = 0

    for (let i = 1; i <= 8; i++) {
      let key = `bay${i}`

      if (breakdown[key].includes("Panel")) {
        let nullKey = `preMatchBay${i}`

        // Safeguard against against bays 4 and 5, which will never have null hatches
        let isNullHatch = breakdown.hasOwnProperty(nullKey) && breakdown[nullKey].includes("Panel")

        if (isNullHatch) {
          nullPanelCount++
        } else {
          panelCount++
        }
      }
      if (breakdown[key].includes("Cargo")) {
        cargoCount++
      }
    }

    return (
      <View style={{ flexDirection: 'row', alignItems: 'center' }}>
        <ImageCount
          image={this.nullHatchPanelImage()}
          count={nullPanelCount} />

        <ImageCount
          image={this.hatchPanelImage()}
          count={panelCount} />

        <ImageCount
          image={this.cargoImage()}
          count={cargoCount} />
      </View>
    )
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

    return (
      <View style={{ flexDirection: 'row', alignItems: 'center' }}>
        <ImageCount
          image={this.hatchPanelImage()}
          count={panelCount} />

        <ImageCount
          image={this.cargoImage()}
          count={cargoCount} />
      </View>
    )
  }

  render() {
    return safeRender(
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

        <BreakdownRow data={["Cargo Ship",
          this.getCargoShipDataFor(this.props.redBreakdown),
          this.getCargoShipDataFor(this.props.blueBreakdown)]} />

        <BreakdownRow data={["Rocket 1",
          this.getRocketShipDataFor(this.props.redBreakdown, "Near"),
          this.getRocketShipDataFor(this.props.blueBreakdown, "Near")]} />

        <BreakdownRow data={["Rocket 2",
          this.getRocketShipDataFor(this.props.redBreakdown, "Far"),
          this.getRocketShipDataFor(this.props.blueBreakdown, "Far")]} />

        <BreakdownRow data={["Total Hatch Panels",
          (
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <ImageCount
                image={this.hatchPanelImage()}
                count={this.props.redBreakdown.hatchPanelPoints / 2} />
              <Text>
                {`(+${this.props.redBreakdown.hatchPanelPoints})`}
              </Text>
            </View>
          ),
          (
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <ImageCount
                image={this.hatchPanelImage()}
                count={this.props.blueBreakdown.hatchPanelPoints / 2} />
              <Text>
                {`(+${this.props.blueBreakdown.hatchPanelPoints})`}
              </Text>
            </View>
          )]} subtotal={true} />

        <BreakdownRow data={["Total Points Cargo",
          (
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <ImageCount
                image={this.cargoImage()}
                count={this.props.redBreakdown.cargoPoints / 3} />
              <Text>
                {`(+${this.props.redBreakdown.cargoPoints})`}
              </Text>
            </View>
          ),
          (
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <ImageCount
                image={this.cargoImage()}
                count={this.props.blueBreakdown.cargoPoints / 3} />
              <Text>
                {`(+${this.props.blueBreakdown.cargoPoints})`}
              </Text>
            </View>
          )]} subtotal={true} />

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
