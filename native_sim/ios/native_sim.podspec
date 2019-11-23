#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_sim.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_sim'
  s.version          = '0.0.1'
  s.summary          = 'A native port of the EPA breakpoint chlorination simulator.'
  s.description      = <<-DESC
native_sim is a native port of the EPA's breakpoint chlorination simulation, for use with Flutter/Dart.
                       DESC
  s.homepage         = 'https://github.com.dnys1'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'HumbleMe' => 'humbleme@protonmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    # Adds the boost lib to the library search path  
    'HEADER_SEARCH_PATHS' => '$(HEADER_SEARCH_PATHS) $(BOOST_DIR)' }
  s.swift_version = '5.0'
end
