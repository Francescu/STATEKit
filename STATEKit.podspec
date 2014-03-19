Pod::Spec.new do |s|
  s.name             = "STATEKit"
  s.version          = "0.0.1"
  s.summary          = "STATEKit, State Management for iOS "
  s.description      = <<-DESC
                       An optional longer description of STATEKit

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/Francescu/STATEKit"
  s.source_files = 'Classes/ios/*.m', 'Classes/ios/*.h'
  s.license          = 'MIT'
  s.author           = { "Francescu" => "francescu.santoni@gmail.com" }
  s.source           = { :git => "https://github.com/Francescu/STATEKit.git", :tag => s.version.to_s }


  s.platform     = :ios, '6.0'
  # s.ios.deployment_target = '7.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  # s.source_files = 'Classes'
  s.resources = 'Resources'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks   = 'Foundation'
end
