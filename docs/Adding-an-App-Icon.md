The Blue Alliance for iOS ships with several app icons to commemorate FRC seasons. Adding a new icon for a new season takes a few steps -

Example: [2020 App Icon PR](https://github.com/the-blue-alliance/the-blue-alliance-ios/pull/771)

1. Create an app icon. Be sure to use the official images from [the-blue-alliance/logo](https://github.com/the-blue-alliance/the-blue-alliance-logo) repo. Make sure the icon looks good on a device (nothing is too small - use a tool like [Icon Strike by Flinto](https://www.flinto.com/strike)) and on the web, since these icons are generally used as profile pictures on social media as well.
      * [2019 App Icon](https://github.com/the-blue-alliance/the-blue-alliance-logo/commit/8cd3f7778543704113cbbc5cdcbe5da6c2d318c6)
      * [2020 App Icon](https://github.com/the-blue-alliance/the-blue-alliance-logo/pull/8/commits/d883ef6d99b6ed7fec72ceab4725ec9acc8532f5)
2. Create an @2x and @3x resolution of the app icon as PNGs - the base size for an app icon is 60x60px, so a @2x icon is 120x120px, and a @3x is 180x180px. These should be named like `[Year][Game Name]Icon`, ex: `2019DeepSpaceIcon@2x` and `2019DeepSpaceIcon@3x`. There are helpful tools for this like [ios-icon-generator](https://github.com/smallmuou/ios-icon-generator).
3. Add the icons to the iOS project. Create a new sub-folder under the `App Icons` folder named `[Year][Game Name]Icon` and drag/drop the new app icon images in to that folder.

![](https://zachorr.com/tba/app-icon-folder.png)

4. Add the new icon to the `CFBundleAlternateIcons` dictionary under the `CFBundleIcons` and `CFBundleIcons~ipad` dictionary in `Info.plist`. The key should be the name of the game, since it is used as the display name when selecting an icon.

![](https://zachorr.com/tba/app-icon-plist.png)

5. Build/run the app on iPhone and iPad to make sure the icons got added properly! Icon selection is under Settings.

![](https://zachorr.com/tba/app-icon-settings.png)