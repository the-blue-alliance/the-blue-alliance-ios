Pod::Spec.new do |s|
  s.name             = 'TBAKitTesting'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Helper classes for testing/mocking TBAKit'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/TBAKit/Testing'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '14.0'

  s.source_files = 'Testing/**/*.swift'
  s.resource_bundles = {'TBAKitTesting' => 'Testing/data/**/*.json'}

  s.framework = 'XCTest'

  s.dependency 'TBAKit'
  s.dependency 'TBATestingMocks'
end
