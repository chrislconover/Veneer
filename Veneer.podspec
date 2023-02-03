#
# Be sure to run `pod lib lint Veneer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Veneer'
  s.version          = '0.1.0'
  s.summary          = 'This is not the library you are looking for.'
  s.description      = <<-DESC
Simple facade to avoid vender lock-in of third party loggers.  Used across internal projects, not very interesting otherwise.
                       DESC

  s.homepage         = 'https://github.com/chrislconover/Veneer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chrislconover' => 'github@curiousapplications.com' }
  s.source           = { :git => 'https://github.com/chrislconover/Veneer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target  = '10.13'

  s.source_files = 'Sources/**/*'
end
