platform :ios, '14.0'

inhibit_all_warnings!

if ENV['CI']
  install! 'cocoapods', :share_schemes_for_development_pods => true
end

target 'The Blue Alliance' do
  use_frameworks!

  # Deps
  pod 'BFRImageViewer'
  pod 'PureLayout'
  pod "youtube-ios-player-helper", "~> 1.0.4"

  # Firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/Performance'
  pod 'Firebase/RemoteConfig'

  # Local Deps
  pod 'MyTBAKit', :path => 'Frameworks/MyTBAKit', :testspecs => ['Tests']
  pod 'Search', :path => 'Frameworks/Search', :testspecs => ['Tests']
  pod 'TBAData', :path => 'Frameworks/TBAData', :testspecs => ['Tests']
  pod 'TBAKit', :path => 'Frameworks/TBAKit', :testspecs => ['Tests']
  pod 'TBAOperation', :path => 'Frameworks/TBAOperation', :testspecs => ['Tests']
  pod 'TBAProtocols', :path => 'Frameworks/TBAProtocols', :testspecs => ['Tests']
  pod 'TBAUtils', :path => 'Frameworks/TBAUtils', :testspecs => ['Tests']

  # myTBA
  pod 'GoogleSignIn', '~> 5'

  target 'tba-unit-tests' do
    inherit! :search_paths

    pod 'MyTBAKitTesting', :path => 'Frameworks/MyTBAKit'
    pod 'TBADataTesting', :path => 'Frameworks/TBAData'
    pod 'TBAKitTesting', :path => 'Frameworks/TBAKit'
    pod 'TBATestingMocks', :path => 'Frameworks/TBATestingMocks'
    pod 'TBAOperationTesting', :path => 'Frameworks/TBAOperation'
  end
end

target 'TBA Spotlight Index Extension' do
  use_frameworks!

  pod 'Search', :path => 'Frameworks/Search'
  pod 'TBAData', :path => 'Frameworks/TBAData'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-The Blue Alliance/Pods-The Blue Alliance-acknowledgements.plist',
  'the-blue-alliance-ios/Settings.bundle/Acknowledgements.plist', :remove_destination => true)

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['WARNING_CFLAGS'] ||= ['"-Wno-nullability-completeness"']
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end

    if "#{target}" == "AppAuth"
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.3'
      end
    end
  end
end
