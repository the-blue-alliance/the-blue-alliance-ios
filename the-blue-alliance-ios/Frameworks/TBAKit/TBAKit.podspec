Pod::Spec.new do |s|
  s.name             = 'TBAKit'
  s.version          = '1.0.0-LOCAL'
  s.summary          = 'An Swift wrapper for The Blue Alliance v3 API'

  s.description      = <<-DESC
    TBAKit is an Swift wrapper for The Blue Alliance v3 API
    that offers complete models and requests for the API
                       DESC

  s.homepage         = 'https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/the-blue-alliance-ios/Frameworks/TBAKit'
  s.author           = 'ZachOrr'
  s.source           = { :git => 'https://thebluealliance.com/', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**'

    test_spec.framework = 'XCTest'

    test_spec.dependency 'TBAKitTesting'

    test_spec.resources = 'Tests/data/**'
  end
end
