'use strict';

import { AppRegistry, View } from 'react-native';

import MatchBreakdown from './app/views/MatchBreakdown';
import EventInsights from './app/views/EventInsights';

AppRegistry.registerComponent('MatchBreakdown', () => MatchBreakdown);
AppRegistry.registerComponent('EventInsights', () => EventInsights);

import MatchBreakdown2015 from './app/views/breakdowns/MatchBreakdown2015';
import MatchBreakdown2016 from './app/views/breakdowns/MatchBreakdown2016';
import MatchBreakdown2017 from './app/views/breakdowns/MatchBreakdown2017';
import MatchBreakdown2018 from './app/views/breakdowns/MatchBreakdown2018';
import MatchBreakdown2019 from './app/views/breakdowns/MatchBreakdown2019';
import MatchBreakdownUnsupported from './app/views/breakdowns/MatchBreakdownUnsupported';
import EventInsights2016 from './app/views/event-insights/EventInsights2016';
import EventInsights2017 from './app/views/event-insights/EventInsights2017';
import EventInsights2018 from './app/views/event-insights/EventInsights2018';
import EventInsights2019 from './app/views/event-insights/EventInsights2019';
import EventInsightsUnsupported from './app/views/event-insights/EventInsightsUnsupported';

// These old style routes are deprecated - create new routes like the above
AppRegistry.registerComponent('MatchBreakdown2015', () => MatchBreakdown2015);
AppRegistry.registerComponent('MatchBreakdown2016', () => MatchBreakdown2016);
AppRegistry.registerComponent('MatchBreakdown2017', () => MatchBreakdown2017);
AppRegistry.registerComponent('MatchBreakdown2018', () => MatchBreakdown2018);
AppRegistry.registerComponent('MatchBreakdown2019', () => MatchBreakdown2019);
// Add a few years of people not updating their app
AppRegistry.registerComponent('MatchBreakdown2020', () => MatchBreakdownUnsupported);
AppRegistry.registerComponent('MatchBreakdown2021', () => MatchBreakdownUnsupported);
AppRegistry.registerComponent('MatchBreakdown2022', () => MatchBreakdownUnsupported);
AppRegistry.registerComponent('EventInsights2016', () => EventInsights2016);
AppRegistry.registerComponent('EventInsights2017', () => EventInsights2017);
AppRegistry.registerComponent('EventInsights2018', () => EventInsights2018);
AppRegistry.registerComponent('EventInsights2019', () => EventInsights2019);
AppRegistry.registerComponent('EventInsights2020', () => EventInsightsUnsupported);
AppRegistry.registerComponent('EventInsights2021', () => EventInsightsUnsupported);
AppRegistry.registerComponent('EventInsights2022', () => EventInsightsUnsupported);
