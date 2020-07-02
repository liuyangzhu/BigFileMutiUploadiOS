#
# Be sure to run `pod lib lint BigFileMultiUpload.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BigFileMultiUpload'
  s.version          = 'v0.2.0'
  s.summary          = 'A short description of BigFileMultiUpload.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "一个大文件上传iOS库，有需要的可以根据自己的需求修改"

  s.homepage         = 'https://github.com/amorYin/BigFileMutiUploadiOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'droudrou@hotmail.com' => 'yinzhao@newscctv.cn' }
  s.source           = { :git => 'https://github.com/amorYin/BigFileMutiUploadiOS.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'BigFileMultiUpload/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BigFileMultiUpload' => ['BigFileMultiUpload/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
