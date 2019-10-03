Pod::Spec.new do |s|
  s.name             = 'TBAData'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'Core Data objects for TBA models'
  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/Frameworks/TBAData'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*.swift'
  s.resources = 'Resources/TBA.xcdatamodeld'
  s.resource_bundle = { 'TBAData-Resources' => ['Resources/**/*.plist'] }

  s.dependency 'MyTBAKit' # Needed for API models
  s.dependency 'TBAKit' # Needed for API models
  s.dependency 'TBAUtils' # For NSSet, Calendar, etc. extensions

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'

    test_spec.framework = 'XCTest'

    test_spec.dependency 'TBADataTesting'
  end
end
