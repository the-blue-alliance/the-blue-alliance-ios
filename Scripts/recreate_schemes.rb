require 'xcodeproj'
xcproj = Xcodeproj::Project.open("the-blue-alliance-ios.xcodeproj")
xcproj.recreate_user_schemes
xcproj.save
