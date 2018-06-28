Pod::Spec.new do |s|
s.name         = "FGDownloader"
s.version      = "2.2"
s.summary      = "FGDownloader is used for resume from break point downloading."
s.homepage     = "https://github.com/Insfgg99x/FGDownloader"
s.license      = "MIT"
s.authors      = { "CGPointZero" => "newbox0512@yahoo.com" }
s.source       = { :git => "https://github.com/Insfgg99x/FGDownloader.git", :tag => "2.2" }
s.frameworks   = 'Foundation','UIKit'
s.platform     = :ios, '6.0'
s.source_files = 'FGDownloader/*.{h,m}'
s.requires_arc = true
#s.dependency 'SDWebImage'
#s.dependency 'pop'
end

