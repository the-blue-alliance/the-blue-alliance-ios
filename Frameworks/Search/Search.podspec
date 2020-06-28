Pod::Spec.new do |s|
  s.name             = 'Search'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Search protocols used to index items'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/Search'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '14.0'

  s.dependency 'TBAProtocols' # For Locatable, etc.

  s.source_files = 'Sources/**/*.swift'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'

    test_spec.dependency 'TBAData' # Test our Core Data exporter with our Core Data stack
    test_spec.dependency 'TBADataTesting'

    test_spec.framework = 'XCTest'
  end
end
