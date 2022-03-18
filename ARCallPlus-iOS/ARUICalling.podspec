#
# Be sure to run `pod lib lint ARUICalling.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ARUICalling'
  s.version          = '1.0.0'
  s.summary          = 'A short description of ARUICalling.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/jhdync/ARUICalling'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jhdync' => 'yangjihua2011@126.com' }
  s.source           = { :git => 'https://github.com/jhdync/ARUICalling.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ARUICalling/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ARUICalling' => ['ARUICalling/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  
  s.requires_arc = true
  s.static_framework = true
  
  s.default_subspec = 'RTC'
  s.subspec 'RTC' do |rtc|
    #rtc.dependency 'ARtcKit_iOS'
    framework_path="../../SDK/ARtcKit.framework"
    rtc.pod_target_xcconfig={
        'HEADER_SEARCH_PATHS'=>["$(PODS_TARGET_SRCROOT)/#{framework_path}/Headers"]
    }
    rtc.source_files = 'Source/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm}', 'Source/UI/**/*.{h,m,mm}'
    rtc.ios.framework = ['AVFoundation', 'Accelerate']
    rtc.library = 'c++', 'resolv'
    rtc.resource_bundles = {
      'ARUICallingKitBundle' => ['Resources/*.xcassets', 'Resources/AudioFile']
    }
  end
end
