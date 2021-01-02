Pod::Spec.new do |s|
  s.name             = 'MyTBAKit'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'An Swift wrapper for the MyTBA API'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/MyTBAKit'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '14.0'

  s.source_files = 'Sources/**/*.swift'

  s.dependency 'TBAOperation'
  s.dependency 'TBAUtils' # For Provider

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'

    test_spec.framework = 'XCTest'

    test_spec.dependency 'MyTBAKitTesting'
  end
end
