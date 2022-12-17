Pod::Spec.new do |spec|
  
  spec.name = "DTSDK"
  spec.version = '1.3.3'
  spec.summary = "DTSDK"
  spec.description = "DTSDK"
  spec.ios.deployment_target  = '8.0'
  spec.requires_arc = true
  spec.homepage = "https://gitlab.com/nodetower/roiquery-sdk/ios/ios-roiquery-sdk.git"
  spec.author = { "" => "" }
  spec.source = { :git => "https://gitlab.com/nodetower/roiquery-sdk/ios/ios-roiquery-sdk.git", :tag => 'v' + spec.version.to_s }
  
  spec.frameworks       = 'Foundation', 'SystemConfiguration', 'CoreGraphics', 'Security'
  spec.libraries        = 'sqlite3', 'z'
  spec.source_files = "**/*.{h,m,mm,c,cc,cpp,metal}", "**/**/*.{h,m,mm,c,cc,cpp,metal}", 
  spec.public_header_files = "**/*.{h}"  
  spec.pod_target_xcconfig = {'EXCLUDED_ARCHS [sdk = iphonesimulator *]'=>'arm64'}
end

