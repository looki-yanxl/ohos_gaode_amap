#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint xbr_gaode_navi_amap.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'xbr_gaode_amap'
  s.version          = '0.0.1'
  s.summary          = 'include amap,search,location'
  s.description      = <<-DESC
include amap,search,location
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'AMap3DMap'
  s.dependency 'AMapSearch'
  s.dependency 'AMapLocation'
  s.platform = :ios, '9.0'
  s.static_framework = true
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
