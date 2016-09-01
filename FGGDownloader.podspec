Pod::Spec.new do |s|
s.name         = "FGGDownloader"
s.version      = "1.0"
s.summary      = "FGGDownloader is used for resume from break point downloading."
s.homepage     = "https://github.com/Insfgg99x/FGGDownloader"
s.license      = "MIT"
s.authors      = { "CGPointZero" => "newbox0512@yahoo.com" }
s.source       = { :git => "https://github.com/Insfgg99x/FGGDownloader.git", :tag => "1.0" }
s.frameworks   = 'Foundation','UIKit'
s.platform     = :ios, '6.0'
s.source_files = 'FGGDownloader/*.{h,m}'
s.requires_arc = true
#s.dependency 'SDWebImage'
#s.dependency 'pop'
end

