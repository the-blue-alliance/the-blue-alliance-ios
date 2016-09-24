source 'https://github.com/CocoaPods/Specs.git'
target 'the-blue-alliance'

platform :ios, '9.0'
pod 'TBAKit'
pod 'youtube-ios-player-helper', '~> 0.1.4'
pod 'OrderedDictionary'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-the-blue-alliance/Pods-the-blue-alliance-acknowledgements.plist',
  'the-blue-alliance-ios/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
