'use strict';

import React from 'react';
import {
    Text,
    View
} from 'react-native';
import TableSectionHeader from '../componets/TableSectionHeader';
import InsightRow from '../componets/InsightRow';
import { round } from '../helpers/number';
import {
  scoreFor,
  percentageFor,
  bonusStat,
  highScoreString,
} from '../helpers/insights';

export default class EventInsights2019 extends React.Component {
  render() {
    return (
      <View>
        {/* Match Stats */}
        <TableSectionHeader>Match Stats</TableSectionHeader>

        <InsightRow title='High Score'
                    qual={highScoreString(this.props.qual, 'high_score')}
                    playoff={highScoreString(this.props.playoff, 'high_score')}/>

        <InsightRow title='Average Match Score'
                    qual={scoreFor(this.props.qual, 'average_score')}
                    playoff={scoreFor(this.props.playoff, 'average_score')}/>

        <InsightRow title='Average Winning Score'
                    qual={scoreFor(this.props.qual, 'average_win_score')}
                    playoff={scoreFor(this.props.playoff, 'average_win_score')}/>

        <InsightRow title='Average Win Margin'
                    qual={scoreFor(this.props.qual, 'average_win_margin')}
                    playoff={scoreFor(this.props.playoff, 'average_win_margin')}/>

        <InsightRow title='Average Sandstorm Bonus Points'
                    qual={scoreFor(this.props.qual, 'average_sandstorm_bonus_auto')}
                    playoff={scoreFor(this.props.playoff, 'average_sandstorm_bonus_auto')}/>

        <InsightRow title='Average Hatch Panel Points'
                    qual={scoreFor(this.props.qual, 'average_hatch_panel_points')}
                    playoff={scoreFor(this.props.playoff, 'average_hatch_panel_points')}/>

        <InsightRow title='Average Cargo Points'
                    qual={scoreFor(this.props.qual, 'average_cargo_points')}
                    playoff={scoreFor(this.props.playoff, 'average_cargo_points')}/>

        <InsightRow title='Average HAB Climb Points'
                    qual={percentageFor(this.props.qual, 'average_hab_climb_teleop')}
                    playoff={percentageFor(this.props.playoff, 'average_hab_climb_teleop')}/>

        <InsightRow title='Average Foul Points'
                    qual={scoreFor(this.props.qual, 'average_foul_score')}
                    playoff={scoreFor(this.props.playoff, 'average_foul_score')}/>

        <InsightRow title='Average Score'
                    qual={scoreFor(this.props.qual, 'average_score')}
                    playoff={scoreFor(this.props.playoff, 'average_score')}/>

        {/* Match Stats */}
        <TableSectionHeader>Bonus Stats (# successful / # opportunities)</TableSectionHeader>

        <InsightRow title='Cross HAB Line'
                    qual={bonusStat(this.props.qual, 'cross_hab_line_count')}
                    playoff={bonusStat(this.props.playoff, 'cross_hab_line_count')}/>

        <InsightRow title='Cross HAB Line in Sandstorm'
                    qual={bonusStat(this.props.qual, 'cross_hab_line_sandstorm_count')}
                    playoff={bonusStat(this.props.playoff, 'cross_hab_line_sandstorm_count')}/>

        <InsightRow title='Complete 1 Rocket'
                    qual={bonusStat(this.props.qual, 'complete_1_rocket_count')}
                    playoff={bonusStat(this.props.playoff, 'complete_1_rocket_count')}/>

        <InsightRow title='Complete 2 Rockets'
                    qual={bonusStat(this.props.qual, 'complete_2_rockets_count')}
                    playoff={bonusStat(this.props.playoff, 'complete_2_rockets_count')}/>

        <InsightRow title='Complete Rocket RP'
                    qual={bonusStat(this.props.qual, 'rocket_rp_achieved')}
                    playoff={bonusStat(this.props.playoff, 'rocket_rp_achieved')}/>

        <InsightRow title='Level 1 HAB Climb'
                    qual={bonusStat(this.props.qual, 'level1_climb_count')}
                    playoff={bonusStat(this.props.playoff, 'level1_climb_count')}/>

        <InsightRow title='Level 2 HAB Climb'
                    qual={bonusStat(this.props.qual, 'level2_climb_count')}
                    playoff={bonusStat(this.props.playoff, 'level2_climb_count')}/>

        <InsightRow title='Level 3 HAB Climb'
                    qual={bonusStat(this.props.qual, 'level3_climb_count')}
                    playoff={bonusStat(this.props.playoff, 'level3_climb_count')}/>

        <InsightRow title='"HAB Docking RP'
                qual={bonusStat(this.props.qual, 'climb_rp_achieved')}
                playoff={bonusStat(this.props.playoff, 'climb_rp_achieved')}/>

        <InsightRow title='"Unicorn Matches" (Win + Complete Rocket + HAB Docking)'
                    qual={bonusStat(this.props.qual, 'unicorn_matches')}
                    playoff={bonusStat(this.props.playoff, 'unicorn_matches')}/>

      </View>
    );
  }
}
