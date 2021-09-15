Pod::Spec.new do |s|
  s.name             = 'MyTBAKitTesting'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Helper classes for testing/mocking MyTBAKit'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/MyTBAKit/Testing'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '15.0'

  s.source_files = 'Testing/**/*.swift'
  s.resource_bundles = {'MyTBAKitTesting' => 'Testing/data/**/*.json'}

  s.framework = 'XCTest'

  s.dependency 'MyTBAKit'
  s.dependency 'TBATestingMocks'
end
