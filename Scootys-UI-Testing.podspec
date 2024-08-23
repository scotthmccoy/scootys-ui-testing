Pod::Spec.new do |s|
    s.name         = "Scootys-UI-Testing"
    s.version      = "1.0.0"
    s.summary      = "Collection of UI Testing Utilities"
    s.homepage     = "http://vrtcal.com"
    s.license = { :type => 'Copyright', :text => <<-LICENSE
                   Copyright 2024 Scott McCoy
                  LICENSE
                }
    s.author       = { "Scott McCoy" => "scotthmccoy@gmail.com" }
    
    s.source       = { :git => "https://github.com/scotthmccoy/scootys-ui-testing.git", :tag => "#{s.version}" }
    s.source_files = "Code/**/*.swift"
    s.swift_versions = ["5.0"]

    s.platform = :ios
    s.ios.deployment_target  = '12.0'
    s.framework      = "XCTest"
end
