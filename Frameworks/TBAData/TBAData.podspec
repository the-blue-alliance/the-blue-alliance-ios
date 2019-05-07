Pod::Spec.new do |s|
  s.name             = 'TBAData'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Core Data models and classes for TBA'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/TBAData'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*'
  s.resource = 'Resources/TBA.xcdatamodeld'
  s.ios.resource_bundles = { 'TBAData' => 'Resources/**/*' }

  s.static_framework = true

  s.dependency 'Crashlytics'
  s.dependency 'MyTBAKit'
  s.dependency 'TBAKit'
  s.dependency 'TBAUtilities'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*'

    test_spec.framework = 'XCTest'

    test_spec.dependency 'TBADataTesting'
  end
end
