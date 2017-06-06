'use strict';

import React from 'react';
import {
    Text,
    View
} from 'react-native';
import TableSectionHeader from '../componets/TableSectionHeader';
import InsightRow from '../componets/InsightRow';

export default class EventInsights2017 extends React.Component {
  
  round(num) {
    return (Math.round(num * 100) / 100).toFixed(2)
  }

  highScoreString(highScoreData) {
    if (highScoreData.length != 3) {
      return highScoreData.join(' ')
    }
    return highScoreData[0] + ' in ' + highScoreData[2]
  }

  bonusStat(bonusData) {
    if (bonusData.length != 3) {
      return bonusData.join(' / ')
    }
    return bonusData[0] + ' / ' + bonusData[1] + ' = ' + this.round(bonusData[2]) + '%'
  }

  render() {

    return (
      <View>
        {/* Match Stats */}
        <TableSectionHeader>Match Stats</TableSectionHeader>

        {/* TOOD: Push these out to matches... */}
        <InsightRow title='Highest Pressure (kPa)'
                    qual={'Quals: ' + this.highScoreString(this.props.qual.high_kpa)}
                    playoff={'Playoffs: ' + this.highScoreString(this.props.playoff.high_kpa)}/>

        <InsightRow title='High Score'
                    qual={'Quals: ' + this.props.qual.high_score[0] + ' in ' + this.props.qual.high_score[2]}
                    playoff={'Playoffs: ' + this.props.playoff.high_score[0] + ' in ' + this.props.playoff.high_score[2]}/>

        <InsightRow title='Average Match Score'
                    qual={this.round(this.props.qual.average_score)}
                    playoff={this.round(this.props.playoff.average_score)}/>

        <InsightRow title='Average Winning Score'
                    qual={this.round(this.props.qual.average_win_score)}
                    playoff={this.round(this.props.playoff.average_win_score)}/>

        <InsightRow title='Average Win Margin'
                    qual={this.round(this.props.qual.average_win_margin)}
                    playoff={this.round(this.props.playoff.average_win_margin)}/>

        <InsightRow title='Average Mobility Points'
                    qual={this.round(this.props.qual.average_mobility_points_auto)}
                    playoff={this.round(this.props.playoff.average_mobility_points_auto)}/>

        <InsightRow title='Average Rotor Points'
                    qual={this.round(this.props.qual.average_rotor_points)}
                    playoff={this.round(this.props.playoff.average_rotor_points)}/>

        <InsightRow title='Average Fuel Points'
                    qual={this.round(this.props.qual.average_fuel_points)}
                    playoff={this.round(this.props.playoff.average_fuel_points)}/>

        <InsightRow title='Average High Goal'
                    qual={this.round(this.props.qual.average_high_goals)}
                    playoff={this.round(this.props.playoff.average_high_goals)}/>

        <InsightRow title='Average Low Goal'
                    qual={this.round(this.props.qual.average_low_goals)}
                    playoff={this.round(this.props.playoff.average_low_goals)}/>

        <InsightRow title='Average Takeoff (Climb) Points'
                    qual={this.round(this.props.qual.average_takeoff_points_teleop)}
                    playoff={this.round(this.props.playoff.average_takeoff_points_teleop)}/>

        <InsightRow title='Average Foul Score'
                    qual={this.round(this.props.qual.average_foul_score)}
                    playoff={this.round(this.props.playoff.average_foul_score)}/>

        {/* Match Stats */}
        <TableSectionHeader>Bonus Stats (# successful / # opportunities)</TableSectionHeader>

        <InsightRow title='Auto Mobility'
                    qual={this.bonusStat(this.props.qual.mobility_counts)}
                    playoff={this.bonusStat(this.props.playoff.mobility_counts)}/>

        <InsightRow title='Teleop Takeoff (Climb)'
                    qual={this.bonusStat(this.props.qual.takeoff_counts)}
                    playoff={this.bonusStat(this.props.playoff.takeoff_counts)}/>

        <InsightRow title='Pressure Bonus (kPa Achieved)'
                    qual={this.bonusStat(this.props.qual.kpa_achieved)}
                    playoff={this.bonusStat(this.props.playoff.kpa_achieved)}/>

        <InsightRow title='Rotor 1 Engaged (Auto)'
                    qual={this.bonusStat(this.props.qual.rotor_1_engaged_auto)}
                    playoff={this.bonusStat(this.props.playoff.rotor_1_engaged_auto)}/>

        <InsightRow title='Rotor 2 Engaged (Auto)'
                    qual={this.bonusStat(this.props.qual.rotor_2_engaged_auto)}
                    playoff={this.bonusStat(this.props.playoff.rotor_2_engaged_auto)}/>

        <InsightRow title='Rotor 1 Engaged'
                    qual={this.bonusStat(this.props.qual.rotor_1_engaged)}
                    playoff={this.bonusStat(this.props.playoff.rotor_1_engaged)}/>

        <InsightRow title='Rotor 2 Engaged'
                    qual={this.bonusStat(this.props.qual.rotor_2_engaged)}
                    playoff={this.bonusStat(this.props.playoff.rotor_2_engaged)}/>

        <InsightRow title='Rotor 3 Engaged'
                    qual={this.bonusStat(this.props.qual.rotor_3_engaged)}
                    playoff={this.bonusStat(this.props.playoff.rotor_3_engaged)}/>

        <InsightRow title='Rotor 4 Engaged'
                    qual={this.bonusStat(this.props.qual.rotor_4_engaged)}
                    playoff={this.bonusStat(this.props.playoff.rotor_4_engaged)}/>

      </View>
    );
  }
}
