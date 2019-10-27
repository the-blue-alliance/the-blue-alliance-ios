import React from 'react';
import { NativeModules, Text, View } from "react-native";
import { safeRender } from '../helpers/safeRender';

import EventInsights2016 from './event-insights/EventInsights2016';
import EventInsights2017 from './event-insights/EventInsights2017';
import EventInsights2018 from './event-insights/EventInsights2018';
import EventInsights2019 from './event-insights/EventInsights2019';

export default class MatchBreakdown extends React.Component {
  view(year) {
    if (this.props.year == 2016) {
      return <EventInsights2016 {...this.props} />
    } else if (this.props.year == 2017) {
      return <EventInsights2017 {...this.props} />
    } else if (this.props.year == 2018) {
      return <EventInsights2018 {...this.props} />
    } else if (this.props.year == 2019) {
      return <EventInsights2019 {...this.props} />
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
