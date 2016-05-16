Pod::Spec.new do |s|
  s.name             = "LPPhotoViewer-swift"
  s.version          = "0.0.1"
  s.summary          = "a simple photo browser"
  s.description      = <<-DESC
                       a simple photo browser with custom-built transition efftect in swift
                       DESC
  s.homepage         = "https://github.com/litt1e-p/LPPhotoViewer-swift"
  s.license          = { :type => 'MIT' }
  s.author           = { "litt1e-p" => "litt1e.p4ul@gmail.com" }
  s.source           = { :git => "https://github.com/litt1e-p/LPPhotoViewer-swift.git", :tag => '0.0.1' }
  s.platform = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'LPPhotoViewer-swift/*'
  s.dependency'SDWebImage', '~> 3.7.5'
  s.frameworks = 'Foundation', 'UIKit'
end
