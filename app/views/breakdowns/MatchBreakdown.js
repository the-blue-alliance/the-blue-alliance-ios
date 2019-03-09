import React from 'react';
import ReactNative from 'react-native';
import breakdownStyle from '../../styles/breakdown';
import images from '../../config/images';

// Override our Image and Text to have specific sizes
const Image = ({ style, ...props }) => <ReactNative.Image style={[breakdownStyle.imageSize, style]} {...props} />;

export default class MatchBreakdown extends React.Component {
  checkImage() {
    return (
      <Image source={images.check} />
    );
  }

  checkCircleImage() {
    return (
      <Image source={images.checkCircle} />
    );
  }

  xImage() {
    return (
      <Image source={images.clear} />
    );
  }

  upArrowImage() {
    return (
      <Image source={images.arrows.up} />
    );
  }

  downArrowImage() {
    return (
      <Image source={images.arrows.down} />
    );
  }
}
