platform :ios, '11.0'

target 'The Blue Alliance' do
  use_frameworks!

  pod 'TBAKit'
  
  # React Native
  pod 'React', :path => 'js/node_modules/react-native', :subspecs => [
    'Core',
    'RCTText',
    'RCTNetwork',
    'RCTImage',
    # 'DevSupport',
    'RCTWebSocket', # needed for debugging
    # Add any other subspecs you want to use in your project
  ]
  # Explicitly include Yoga if you are using RN >= 0.42.0
  pod "Yoga", :path => "js/node_modules/react-native/ReactCommon/yoga"

  # Deps
  pod "youtube-ios-player-helper", "~> 0.1.4"
  pod 'PureLayout'
  pod 'ZIPFoundation'
  
  # Firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Performance'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Storage'

  # MyTBA
  pod 'GoogleSignIn'

  # Crash reporting
  pod 'Fabric', '~> 1.7.6'
  pod 'Crashlytics', '~> 3.10.1'

  target 'tba-unit-tests' do
    inherit! :search_paths
  end
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-The Blue Alliance/Pods-The Blue Alliance-acknowledgements.plist',
  'the-blue-alliance-ios/Settings.bundle/Acknowledgements.plist', :remove_destination => true)

  installer.pods_project.targets.each do |target|
    if "#{target}" == "AppAuth"
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.3'
      end
    end
  end
end
