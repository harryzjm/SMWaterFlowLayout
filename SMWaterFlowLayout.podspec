Pod::Spec.new do |s|

s.name         = "SMWaterFlowLayout"
s.version      = "1.0.0"
s.summary      = "SMWaterFlowLayout is a subclass of UICollectionViewFlowLayout, easy to use."
# s.description  = <<-DESC
# 				 SMWaterFlowLayout is a subclass of UICollectionViewFlowLayout, easy to use.
# 				 DESC

s.homepage     = "https://github.com/harryzjm/SMWaterFlowLayout"
# s.screenshots  = ""

s.license      = { :type => 'MIT', :file => 'LICENSE' }

s.authors            = { "Hares" => "harryzjm@live.com" }
s.social_media_url   = "https://harryzjm.github.io/"

s.ios.deployment_target = "8.0"

s.source       = { :git => "https://github.com/harryzjm/SMWaterFlowLayout.git", :tag => s.version }

s.source_files = ["Source/*.swift", "Source/SMWaterFlowLayout.h"]
s.public_header_files = "Source/SMWaterFlowLayout.h"

s.requires_arc = true

s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

end