Pod::Spec.new do |s|

  s.name = "HidingNavigationBar"
  s.version = "0.3.0"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.summary = "A objc library that manages hiding and showing a Navigation Bar as a user scrolls"
  s.homepage = "https://git.yidian-inc.com:8021/ios//HidingNavigationBar"
  s.author = { "huang shaojun" => "huangshaojun@ydian-inc.com" }
  s.source = { :git => 'https://git.yidian-inc.com:8021/ios/HidingNavigationBar.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.requires_arc = 'true'
  s.source_files = 'HidingNavigationBar/**/*.{h,m}'

end
