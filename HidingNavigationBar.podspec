Pod::Spec.new do |s|

  s.name = "HidingNavigationBar"
  s.version = "0.3.0"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.summary = "A objc library that manages hiding and showing a Navigation Bar as a user scrolls"
  s.homepage = "https://github.com/huangjimmy/HidingNavigationBar"
  s.author = { "huang shaojun" => "jimmy_huang@live.com" }
  s.source = { :git => 'https://github.com/huangjimmy/HidingNavigationBar.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.framework    = 'UIKit'
  s.source_files = 'HidingNavigationBar/**/*.{h,m}'

end
