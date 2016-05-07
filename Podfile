source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
pod 'TBAKit'
pod "youtube-ios-player-helper", "~> 0.1.4"
pod 'OrderedDictionary'
pod 'Valet'
pod 'Google-API-Client'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist',
  'the-blue-alliance-ios/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
