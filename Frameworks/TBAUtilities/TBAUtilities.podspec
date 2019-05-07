Pod::Spec.new do |s|
  s.name             = 'TBAUtilities'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Shared utility classes and extensions for TBA.'

  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/TBAUtilities'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*'

    test_spec.framework = 'XCTest'
  end
end
