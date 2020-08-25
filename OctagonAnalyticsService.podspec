#
# Be sure to run `pod lib lint OctagonAnalyticsService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OctagonAnalyticsService'
  s.version          = '0.4.1'
  s.summary          = 'OctagonAnalyticsService - API provider for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
OctagonAnalyticsService - Kibana API service provider for iOS application.
Kibana is a trademark of Elasticsearch BV, registered in the US and in other countries.
                       DESC

  s.homepage         = 'https://github.com/OctagonMobile/OctagonAnalyticsService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'OctagonMobile' => 'octagon.mobile2020@gmail.com' }
  s.source           = { :git => 'https://github.com/OctagonMobile/OctagonAnalyticsService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  
  s.source_files = 'OctagonAnalyticsService/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OctagonAnalyticsService' => ['OctagonAnalyticsService/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Alamofire'
#   s.dependency 'AlamofireImage'
end
