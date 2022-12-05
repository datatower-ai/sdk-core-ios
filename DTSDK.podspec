Pod::Spec.new do |spec|
  
  spec.name = "DTSDK"
  spec.version = '0.01'
  spec.summary = "DTSDK"
  spec.description = "DTSDK"
  spec.ios.deployment_target  = '10.0'
  spec.requires_arc = true
  spec.homepage = "https://gitlab.com/nodetower/roiquery-sdk/ios/ios-roiquery-sdk.git"
  spec.author = { "" => "" }
  spec.source = { :git => "https://gitlab.com/nodetower/roiquery-sdk/ios/ios-roiquery-sdk.git", :tag => 'v' + spec.version.to_s }
  
  spec.source_files = "**/*.{h,m,mm,c,cc,cpp,metal}", "**/**/*.{h,m,mm,c,cc,cpp,metal}", 
  spec.public_header_files = "**/*.{h}"
  
  spec.user_target_xcconfig  = {
    'EXCLUDED_ARCHS' => 'armv7 i386'
  }
  
end

