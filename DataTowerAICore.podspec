Pod::Spec.new do |spec|
  
  spec.name = "DataTowerAICore"
  spec.version = '2.0.2'
  spec.summary = "DataTowerAICore"
  spec.description = "DataTowerAICore"
  spec.ios.deployment_target  = '11.0'
  spec.requires_arc = true
  spec.homepage = "https://gitlab.com/nodetower/roiquery-sdk/ios/ios-roiquery-sdk.git"
  spec.author = { "" => "" }
  spec.source = { :git => "https://gitlab.com/nodetower/roiquery-sdk/ios/ios-roiquery-sdk.git", :tag => 'v' + spec.version.to_s }
  
  spec.frameworks       = 'QuartzCore','UIKit','Foundation', 'SystemConfiguration', 'CoreGraphics', 'Security' , 'CoreTelephony'
  spec.libraries        = 'sqlite3', 'z'
  spec.source_files = "**/*.{h,m,mm,c,cc,cpp,metal}", "**/**/*.{h,m,mm,c,cc,cpp,metal}", 
  spec.public_header_files = "DataTower/*.{h}"  
  spec.pod_target_xcconfig = {'EXCLUDED_ARCHS[sdk=iphonesimulator*]'=>'armv7 armv7s arm64','EXCLUDED_ARCHS[sdk=iphoneos*]'=>'armv7 armv7s'}
  spec.user_target_xcconfig = {'EXCLUDED_ARCHS[sdk=iphonesim*]'=>'armv7 armv7s arm64','EXCLUDED_ARCHS[sdk=iphoneos*]'=>'armv7 armv7s'}
end

