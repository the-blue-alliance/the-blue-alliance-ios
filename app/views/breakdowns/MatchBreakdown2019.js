import React from "react";
import ReactNative from "react-native";
import { View, Text } from "react-native";
import BreakdownRow from "../../components/BreakdownRow";
import images from "../../config/images";
import ImageCount from "../../components/ImageCount";
import ScoredLocationImage from "../../components/ScoredLocationImage";
import MatchBreakdown from "../breakdowns/MatchBreakdown";
import breakdownStyle from "../../styles/breakdown";

// Override our Image and Text to have specific sizes
const Image = ({ style, ...props }) => (
  <ReactNative.Image style={[breakdownStyle.imageSize, style]} {...props} />
);

export default class MatchBreakdown2019 extends MatchBreakdown {
  nullHatchPanelImage() {
    return (
      <Image
        source={images[2019].hatchPanel}
        style={{ tintColor: "#616161" }}
      />
    );
  }

  hatchPanelImage() {
    return (
      <Image
        source={images[2019].hatchPanel}
        style={{ tintColor: "#ffeb3b" }}
      />
    );
  }

  cargoImage() {
    return (
      <Image source={images[2019].cargo} style={{ tintColor: "#ff6d00" }} />
    );
  }

  getSandstormBonusFor(breakdown, robotNumber) {
    if (
      breakdown["habLineRobot" + robotNumber] == "CrossedHabLineInSandstorm"
    ) {
      let result = breakdown["preMatchLevelRobot" + robotNumber];
      if (result.includes("HabLevel")) {
        let level = result.substr(-1);
        let climbPoints = [3, 6];
        return `Level ${level} (+${climbPoints[level - 1]})`;
      }
    }
    return this.xImage();
  }

  getHABClimbFor(breakdown, robotNumber) {
    let result = breakdown["endgameRobot" + robotNumber];
    if (result.includes("HabLevel")) {
      let level = result.substr(-1);
      let climbPoints = [3, 6, 12];
      return `Level ${level} (+${climbPoints[level - 1]})`;
    }
    return this.xImage();
  }

  getCargoShipDataFor(breakdown) {
    var nullPanelCount = 0;
    var panelCount = 0;
    var cargoCount = 0;

    for (let i = 1; i <= 8; i++) {
      let key = `bay${i}`;

      if (breakdown[key].includes("Panel")) {
        let nullKey = `preMatchBay${i}`;

        // Safeguard against against bays 4 and 5, which will never have null hatches
        let isNullHatch =
          breakdown.hasOwnProperty(nullKey) &&
          breakdown[nullKey].includes("Panel");

        if (isNullHatch) {
          nullPanelCount++;
        } else {
          panelCount++;
        }
      }
      if (breakdown[key].includes("Cargo")) {
        cargoCount++;
      }
    }

    return (
      <View style={{ flexDirection: "row", alignItems: "center" }}>
        <ImageCount image={this.nullHatchPanelImage()} count={nullPanelCount} />

        <ImageCount image={this.hatchPanelImage()} count={panelCount} />

        <ImageCount image={this.cargoImage()} count={cargoCount} />
      </View>
    );
  }

  getRocketShipDataFor(breakdown, rocketLocation) {
    var locations = [
      "topLeftRocket",
      "topRightRocket",
      "midLeftRocket",
      "midRightRocket",
      "lowLeftRocket",
      "lowRightRocket"
    ];
    var panelCount = 0;
    var cargoCount = 0;
    locations.forEach(location => {
      if (breakdown[location + rocketLocation].includes("Panel")) {
        panelCount++;
      }
      if (breakdown[location + rocketLocation].includes("Cargo")) {
        cargoCount++;
      }
    });

    return (
      <View style={{ flexDirection: "row", alignItems: "center" }}>
        <ImageCount image={this.hatchPanelImage()} count={panelCount} />

        <ImageCount image={this.cargoImage()} count={cargoCount} />
      </View>
    );
  }

  getScoredDisplayForRocket(breakdown, level, location) {
    const leftScoringKey = `${level}LeftRocket${location}`;
    const rightScoringKey = `${level}RightRocket${location}`;

    return (
      <View
        style={{ flexDirection: "row", alignItems: "center", width: "100%" }}
      >
        <View
          style={{
            flexDirection: "row",
            width: "50%",
            justifyContent: "center"
          }}
        >
          <ScoredLocationImage
            scoredString={
              location == "Near"
                ? breakdown[leftScoringKey]
                : breakdown[rightScoringKey]
            }
            cargoImage={this.cargoImage()}
            hatchPanelImage={this.hatchPanelImage()}
            nullHatchPanelImage={this.nullHatchPanelImage()}
          />
        </View>
        <View
          style={{
            flexDirection: "row",
            width: "50%",
            justifyContent: "center"
          }}
        >
          <ScoredLocationImage
            scoredString={
              location == "Near"
                ? breakdown[rightScoringKey]
                : breakdown[leftScoringKey]
            }
            cargoImage={this.cargoImage()}
            hatchPanelImage={this.hatchPanelImage()}
            nullHatchPanelImage={this.nullHatchPanelImage()}
          />
        </View>
      </View>
    );
  }

  getScoredDisplayForCargoShip(breakdown, isRed) {
    return (
      <View
        style={{ flexDirection: "column", alignItems: "center", width: "100%" }}
      >
        <View
          style={{ flexDirection: "row", alignItems: "center", width: "100%" }}
        >
          <View
            style={{
              flexDirection: "row",
              width: "25%",
              justifyContent: "center"
            }}
          >
            <ScoredLocationImage
              scoredString={isRed ? breakdown.bay4 : breakdown.bay1}
              preMatchString={isRed ? "" : breakdown.preMatchBay1}
              cargoImage={this.cargoImage()}
              hatchPanelImage={this.hatchPanelImage()}
              nullHatchPanelImage={this.nullHatchPanelImage()}
            />
          </View>
          <View
            style={{
              flexDirection: "row",
              width: "25%",
              justifyContent: "center"
            }}
          >
            <ScoredLocationImage
              scoredString={isRed ? breakdown.bay3 : breakdown.bay2}
              preMatchString={
                isRed ? breakdown.preMatchBay3 : breakdown.preMatchBay2
              }
              cargoImage={this.cargoImage()}
              hatchPanelImage={this.hatchPanelImage()}
              nullHatchPanelImage={this.nullHatchPanelImage()}
            />
          </View>
          <View
            style={{
              flexDirection: "row",
              width: "25%",
              justifyContent: "center"
            }}
          >
            <ScoredLocationImage
              scoredString={isRed ? breakdown.bay2 : breakdown.bay3}
              preMatchString={
                isRed ? breakdown.preMatchBay2 : breakdown.preMatchBay3
              }
              cargoImage={this.cargoImage()}
              hatchPanelImage={this.hatchPanelImage()}
              nullHatchPanelImage={this.nullHatchPanelImage()}
            />
          </View>
          <View
            style={{
              flexDirection: "row",
              width: "25%",
              justifyContent: "center"
            }}
          >
            <ScoredLocationImage
              scoredString={isRed ? breakdown.bay1 : breakdown.bay4}
              preMatchString={isRed ? breakdown.preMatchBay1 : ""}
              cargoImage={this.cargoImage()}
              hatchPanelImage={this.hatchPanelImage()}
              nullHatchPanelImage={this.nullHatchPanelImage()}
            />
          </View>
        </View>
        <View
          style={{ flexDirection: "row", alignItems: "center", width: "100%" }}
        >
          <View
            style={{
              flexDirection: "row",
              width: "25%",
              justifyContent: "center"
            }}
          >
            <ScoredLocationImage
              scoredString={isRed ? breakdown.bay5 : breakdown.bay8}
              preMatchString={isRed ? "" : breakdown.preMatchBay8}
              cargoImage={this.cargoImage()}
              hatchPanelImage={this.hatchPanelImage()}
              nullHatchPanelImage={this.nullHatchPanelImage()}
            />
          </View>
          <View
            style={{
              flexDirection: "row",
              width: "25%",
              justifyContent: "center"
            }}
          >
            <ScoredLocationImage
              scoredString={isRed ? breakdown.bay6 : breakdown.bay7}
              preMatchString={
                isRed ? breakdown.preMatchBay6 : breakdown.preMatchBay7
              }
              cargoImage={this.cargoImage()}
              hatchPanelImage={this.hatchPanelImage()}
              nullHatchPanelImage={this.nullHatchPanelImage()}
            />
          </View>
          <View
            style={{
              flexDirection: "row",
              width: "25%",
              justifyContent: "center"
            }}
          >
            <ScoredLocationImage
              scoredString={isRed ? breakdown.bay7 : breakdown.bay6}
              preMatchString={
                isRed ? breakdown.preMatchBay7 : breakdown.preMatchBay6
              }
              cargoImage={this.cargoImage()}
              hatchPanelImage={this.hatchPanelImage()}
              nullHatchPanelImage={this.nullHatchPanelImage()}
            />
          </View>
          <View
            style={{
              flexDirection: "row",
              width: "25%",
              justifyContent: "center"
            }}
          >
            <ScoredLocationImage
              scoredString={isRed ? breakdown.bay8 : breakdown.bay5}
              preMatchString={isRed ? breakdown.preMatchBay8 : ""}
              cargoImage={this.cargoImage()}
              hatchPanelImage={this.hatchPanelImage()}
              nullHatchPanelImage={this.nullHatchPanelImage()}
            />
          </View>
        </View>
      </View>
    );
  }

  renderTeamSection() {
    return (
      <BreakdownRow
        data={["Teams", this.props.redTeams, this.props.blueTeams]}
        vertical={true}
        subtotal={true}
      />
    );
  }

  renderSandstormSection() {
    return (
      <>
        <BreakdownRow
          data={[
            "Robot 1 Sandstorm Bonus",
            this.getSandstormBonusFor(this.props.redBreakdown, 1),
            this.getSandstormBonusFor(this.props.blueBreakdown, 1)
          ]}
        />

        <BreakdownRow
          data={[
            "Robot 2 Sandstorm Bonus",
            this.getSandstormBonusFor(this.props.redBreakdown, 2),
            this.getSandstormBonusFor(this.props.blueBreakdown, 2)
          ]}
        />

        <BreakdownRow
          data={[
            "Robot 3 Sandstorm Bonus",
            this.getSandstormBonusFor(this.props.redBreakdown, 3),
            this.getSandstormBonusFor(this.props.blueBreakdown, 3)
          ]}
        />

        <BreakdownRow
          data={[
            "Total Sandstorm Bonus",
            this.props.redBreakdown.sandStormBonusPoints,
            this.props.blueBreakdown.sandStormBonusPoints
          ]}
          total={true}
        />
      </>
    );
  }

  renderGameObjectsSection() {
    return (
      <>
        <BreakdownRow
          data={[
            "Cargo Ship",
            this.getCargoShipDataFor(this.props.redBreakdown),
            this.getCargoShipDataFor(this.props.blueBreakdown)
          ]}
        />

        <BreakdownRow
          data={[
            "Rocket 1",
            this.getRocketShipDataFor(this.props.redBreakdown, "Near"),
            this.getRocketShipDataFor(this.props.blueBreakdown, "Near")
          ]}
        />

        <BreakdownRow
          data={[
            "Rocket 2",
            this.getRocketShipDataFor(this.props.redBreakdown, "Far"),
            this.getRocketShipDataFor(this.props.blueBreakdown, "Far")
          ]}
        />

        <BreakdownRow
          data={[
            "Total Hatch Panels",
            <View style={{ flexDirection: "row", alignItems: "center" }}>
              <ImageCount
                image={this.hatchPanelImage()}
                count={this.props.redBreakdown.hatchPanelPoints / 2}
              />
              <Text>{`(+${this.props.redBreakdown.hatchPanelPoints})`}</Text>
            </View>,
            <View style={{ flexDirection: "row", alignItems: "center" }}>
              <ImageCount
                image={this.hatchPanelImage()}
                count={this.props.blueBreakdown.hatchPanelPoints / 2}
              />
              <Text>{`(+${this.props.blueBreakdown.hatchPanelPoints})`}</Text>
            </View>
          ]}
          subtotal={true}
        />

        <BreakdownRow
          data={[
            "Total Points Cargo",
            <View style={{ flexDirection: "row", alignItems: "center" }}>
              <ImageCount
                image={this.cargoImage()}
                count={this.props.redBreakdown.cargoPoints / 3}
              />
              <Text>{`(+${this.props.redBreakdown.cargoPoints})`}</Text>
            </View>,
            <View style={{ flexDirection: "row", alignItems: "center" }}>
              <ImageCount
                image={this.cargoImage()}
                count={this.props.blueBreakdown.cargoPoints / 3}
              />
              <Text>{`(+${this.props.blueBreakdown.cargoPoints})`}</Text>
            </View>
          ]}
          subtotal={true}
        />
      </>
    );
  }

  renderTeleopSummary() {
    return (
      <>
        <BreakdownRow
          data={[
            "Robot 1 HAB Climb",
            this.getHABClimbFor(this.props.redBreakdown, 1),
            this.getHABClimbFor(this.props.blueBreakdown, 1)
          ]}
        />

        <BreakdownRow
          data={[
            "Robot 2 HAB Climb",
            this.getHABClimbFor(this.props.redBreakdown, 2),
            this.getHABClimbFor(this.props.blueBreakdown, 2)
          ]}
        />

        <BreakdownRow
          data={[
            "Robot 3 HAB Climb",
            this.getHABClimbFor(this.props.redBreakdown, 3),
            this.getHABClimbFor(this.props.blueBreakdown, 3)
          ]}
        />

        <BreakdownRow
          data={[
            "HAB Climb Points",
            this.props.redBreakdown.habClimbPoints,
            this.props.blueBreakdown.habClimbPoints
          ]}
          subtotal={true}
        />

        <BreakdownRow
          data={[
            "Total Teleop",
            this.props.redBreakdown.teleopPoints,
            this.props.blueBreakdown.teleopPoints
          ]}
          total={true}
        />

        <BreakdownRow
          data={[
            "Complete Rocket",
            this.props.redBreakdown.completeRocketRankingPoint
              ? this.checkImage()
              : this.xImage(),
            this.props.blueBreakdown.completeRocketRankingPoint
              ? this.checkImage()
              : this.xImage()
          ]}
        />

        <BreakdownRow
          data={[
            "HAB Docking",
            this.props.redBreakdown.habDockingRankingPoint
              ? this.checkImage()
              : this.xImage(),
            this.props.blueBreakdown.habDockingRankingPoint
              ? this.checkImage()
              : this.xImage()
          ]}
        />

        <BreakdownRow
          data={[
            "Fouls",
            ["+", this.props.redBreakdown.foulPoints],
            ["+", this.props.blueBreakdown.foulPoints]
          ]}
        />

        <BreakdownRow
          data={[
            "Adjustments",
            this.props.redBreakdown.adjustPoints,
            this.props.blueBreakdown.adjustPoints
          ]}
        />

        <BreakdownRow
          data={[
            "Total Score",
            this.props.redBreakdown.totalPoints,
            this.props.blueBreakdown.totalPoints
          ]}
          total={true}
        />

        {this.props.compLevel == "qm" ? (
          <BreakdownRow
            data={[
              "Ranking Points",
              ["+", this.props.redBreakdown.rp, " RP"],
              ["+", this.props.blueBreakdown.rp, " RP"]
            ]}
          />
        ) : null}
      </>
    );
  }

  renderScoringLocationBreakdownSection() {
    return (
      <>
        <BreakdownRow
          data={[
            "Rocket 1 Top",
            this.getScoredDisplayForRocket(
              this.props.redBreakdown,
              "top",
              "Near"
            ),
            this.getScoredDisplayForRocket(
              this.props.blueBreakdown,
              "top",
              "Near"
            )
          ]}
        />
        <BreakdownRow
          data={[
            "Rocket 1 Mid",
            this.getScoredDisplayForRocket(
              this.props.redBreakdown,
              "mid",
              "Near"
            ),
            this.getScoredDisplayForRocket(
              this.props.blueBreakdown,
              "mid",
              "Near"
            )
          ]}
        />
        <BreakdownRow
          data={[
            "Rocket 1 Low",
            this.getScoredDisplayForRocket(
              this.props.redBreakdown,
              "low",
              "Near"
            ),
            this.getScoredDisplayForRocket(
              this.props.blueBreakdown,
              "low",
              "Near"
            )
          ]}
        />
        <BreakdownRow
          data={[
            "Cargo Ship",
            this.getScoredDisplayForCargoShip(this.props.redBreakdown, true),
            this.getScoredDisplayForCargoShip(this.props.blueBreakdown, false)
          ]}
        />
        <BreakdownRow
          data={[
            "Rocket 2 Top",
            this.getScoredDisplayForRocket(
              this.props.redBreakdown,
              "top",
              "Far"
            ),
            this.getScoredDisplayForRocket(
              this.props.blueBreakdown,
              "top",
              "Far"
            )
          ]}
        />
        <BreakdownRow
          data={[
            "Rocket 2 Mid",
            this.getScoredDisplayForRocket(
              this.props.redBreakdown,
              "mid",
              "Far"
            ),
            this.getScoredDisplayForRocket(
              this.props.blueBreakdown,
              "mid",
              "Far"
            )
          ]}
        />
        <BreakdownRow
          data={[
            "Rocket 2 Low",
            this.getScoredDisplayForRocket(
              this.props.redBreakdown,
              "low",
              "Far"
            ),
            this.getScoredDisplayForRocket(
              this.props.blueBreakdown,
              "low",
              "Far"
            )
          ]}
        />
      </>
    );
  }

  render() {
    return(
      <View style={breakdownStyle.container}>
        {this.renderTeamSection()}

        {this.renderSandstormSection()}

        {this.renderGameObjectsSection()}

        {this.renderTeleopSummary()}

        {this.renderScoringLocationBreakdownSection()}
      </View>
    );
  }
}
