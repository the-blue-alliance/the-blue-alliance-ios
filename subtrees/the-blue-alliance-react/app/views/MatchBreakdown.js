import React from 'react';
import { NativeModules, Text, View } from "react-native";
import { safeRender } from '../helpers/safeRender';

import MatchBreakdown2015 from './breakdowns/MatchBreakdown2015';
import MatchBreakdown2016 from './breakdowns/MatchBreakdown2016';
import MatchBreakdown2017 from './breakdowns/MatchBreakdown2017';
import MatchBreakdown2018 from './breakdowns/MatchBreakdown2018';
import MatchBreakdown2019 from './breakdowns/MatchBreakdown2019';

export default class MatchBreakdown extends React.Component {
  view(year) {
    if (this.props.year == 2015) {
      return <MatchBreakdown2015 {...this.props} />
    } else if (this.props.year == 2016) {
      return <MatchBreakdown2016 {...this.props} />
    } else if (this.props.year == 2017) {
      return <MatchBreakdown2017 {...this.props} />
    } else if (this.props.year == 2018) {
      return <MatchBreakdown2018 {...this.props} />
    } else if (this.props.year == 2019) {
      return <MatchBreakdown2019 {...this.props} />
    } else {
      try {
        var TBACallbackManager = NativeModules.TBACallbackManager;
        TBACallbackManager.moduleUnsupported()
      } catch {}
      return <View />
    }
  }

  render() {
    var view = this.view(this.props.year)
    return safeRender(view)
  }
}
