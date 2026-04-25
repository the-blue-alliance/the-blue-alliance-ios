Setup Firebase
---
1. Navigate to the [Firebase Console](https://console.firebase.google.com/)
2. Click `Add Project`
3. Enter a project name to work with - preferably something namespace'd to yourself (ex: `zach-tba-dev`)
4. After your project is done setting up, click your newly created project
5. On the landing page, click `Add Firebase to your iOS app`
6. Enter a locally namespaced bundle identifier (ex: `com.the-blue-alliance.tba.zach-tba-dev`)
7. Click `Register App`
8. Download the `GoogleService-Info.plist` (we'll use this in the [Configure Project](#configure-project) step)

Configure Project
---
This step assumes you've completed all of the steps from the [Setup guide](https://github.com/the-blue-alliance/the-blue-alliance-ios/wiki/Setup)

1. Open the workspace file (`the-blue-alliance-ios.xcworkspace`)
2. Click `the-blue-alliance-ios` project in the project navigator
3. On the left sidebar, under `Targets` click `The Blue Alliance`
4. Click the `General` tab along the top bar
5. Change `Bundle Identifier` to the bundle identifier you set during the [Setup Firebase](#setup-firebase) step
6. Overwrite the existing `GoogleService-Info.plist` in the `the-blue-alliance-ios/` folder with your newly downloaded `GoogleService-Info.plist`