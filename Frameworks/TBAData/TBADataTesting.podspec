Pod::Spec.new do |s|
  s.name             = 'TBADataTesting'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Helper classes for testing/mocking TBAData'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/TBAData/Testing'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Testing/**/*.swift'

  s.framework = 'XCTest'

  s.dependency 'TBAData'
  s.dependency 'TBAKit'
end
