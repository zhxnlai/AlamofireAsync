#
# Be sure to run `pod lib lint AlamofireAsync.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AlamofireAsync"
  s.version          = "0.1.0"
  s.summary          = "Async extension for Alamofire."

  s.homepage         = "https://github.com/zhxnlai/AlamofireAsync"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Zhixuan Lai" => "zhxnlai@gmail.com" }
  s.source           = { :git => "https://github.com/zhxnlai/AlamofireAsync.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'AlamofireAsync' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire', '~> 3.0'
  s.dependency 'SwiftAsync'
end
