Pod::Spec.new do |s|
  s.name             = 'AppMeasurely'
  s.version          = '1.0.1'
  s.summary          = 'Mobile attribution and analytics SDK for iOS'
  s.description      = 'AppMeasurely iOS SDK for mobile attribution tracking. Track installs, sessions, custom events and revenue.'
  s.homepage         = 'https://appmeasurely.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AppMeasurely' => 'support@appmeasurely.com' }
  s.source           = { :git => 'https://github.com/appmeasurely/ios-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/AppMeasurely/**/*'
end
