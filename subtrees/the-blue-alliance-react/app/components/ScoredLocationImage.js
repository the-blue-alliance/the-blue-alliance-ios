import React from "react";
import { View } from "react-native";

export default class ScoredLocationImage extends React.Component {
  render() {
    const {
      scoredString,
      preMatchString = "",
      cargoImage,
      hatchPanelImage,
      nullHatchPanelImage
    } = this.props;

    const renderCargo = scoredString.includes("Cargo");
    const renderHatchPanel = scoredString.includes("Panel");
    const renderNullHatchPanel = preMatchString.includes("Panel");

    return (
      <>
        {renderCargo && <View style={{ marginRight: -24 }}>{cargoImage}</View>}
        {renderHatchPanel && !renderNullHatchPanel && (
          <View>{hatchPanelImage}</View>
        )}
        {renderNullHatchPanel && <View>{nullHatchPanelImage}</View>}
      </>
    );
  }
}
