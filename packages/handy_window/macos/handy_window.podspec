#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint handy_window.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'handy_window'
  s.version          = '0.1.0'
  s.summary          = 'Manages the top-level application window.'
  s.description      = <<-DESC
Manages the top-level application window. On Linux, provides an easy
way to use Handy windows with modern looking rounded bottom corners.
                       DESC
  s.homepage         = 'https://github.com/canonical/ubuntu-flutter-plugins/tree/main/packages/handy_window'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Canonical Ltd' => 'https://canonical.com/contact-us' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
