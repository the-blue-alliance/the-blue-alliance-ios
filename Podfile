platform :ios, '10.0'
use_frameworks!

target 'the-blue-alliance-ios' do

  pod 'TBAKit'
  
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

  pod "youtube-ios-player-helper", "~> 0.1.4"
  pod 'PureLayout'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-the-blue-alliance-ios/Pods-the-blue-alliance-ios-acknowledgements.plist',
  'the-blue-alliance-ios/Settings.bundle/Acknowledgements.plist', :remove_destination => true)

  installer.pods_project.targets.each do |target|
    if "#{target}" == "AppAuth"
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.3'
      end
    end
  end
end
