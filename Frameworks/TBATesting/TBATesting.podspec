Pod::Spec.new do |s|
  s.name             = 'TBATesting'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Shared class for TBA tests.'

  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/TBATesting'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*'
  s.framework = 'XCTest'

  s.static_framework = true

  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/Messaging'
  s.dependency 'TBAKitTesting'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*'

    test_spec.framework = 'XCTest'
  end
end
