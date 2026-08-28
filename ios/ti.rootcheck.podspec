
Pod::Spec.new do |s|

    s.name         = "ti.rootcheck"
    s.version      = "1.2.0"
    s.summary      = "The ti.rootcheck Titanium module."

    s.description  = <<-DESC
                     Jailbreak / root detection for Titanium apps.
                     DESC

    s.homepage     = "https://github.com/m1ga/ti.rootcheck"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author       = 'Hans Knöchel'

    s.platform     = :ios
    s.ios.deployment_target = '12.0'

    s.source       = { :git => "https://github.com/m1ga/ti.rootcheck.git" }

    s.ios.weak_frameworks = 'UIKit', 'Foundation'

    s.ios.dependency 'TitaniumKit'

    s.public_header_files = 'Classes/*.h'
    s.source_files = 'Classes/*.{h,m,swift}'
  end
