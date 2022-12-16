Pod::Spec.new do |s|
  s.name = "DTSDK"
  s.version = "0.0.1"
  s.summary = "DTSDK"
  s.authors = {""=>""}
  s.homepage = "https://gitlab.com/nodetower/roiquery-sdk/ios/ios-roiquery-sdk.git"
  s.description = "DTSDK"
  s.frameworks = ["Foundation", "SystemConfiguration", "CoreGraphics", "Security"]
  s.libraries = ["sqlite3", "z"]
  s.requires_arc = true
  s.source = -embedded

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/DTSDK.framework'
end
