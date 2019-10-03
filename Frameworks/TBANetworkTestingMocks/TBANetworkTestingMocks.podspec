Pod::Spec.new do |s|
  s.name             = 'TBANetworkTestingMocks'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Shared network mock classes to use for testing in TBA networking frameworks.'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/TBANetworkTestingMocks'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '11.0'

  s.framework = 'XCTest'

  s.source_files = 'Sources/**/*.swift'
end
