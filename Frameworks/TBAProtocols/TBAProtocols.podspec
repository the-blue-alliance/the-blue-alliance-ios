Pod::Spec.new do |s|
  s.name             = 'TBAProtocols'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Shared protocols across TBA.'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/TBAProtocols'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '15.0'

  s.source_files = 'Sources/**/*.swift'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'

    test_spec.framework = 'XCTest'
  end
end
