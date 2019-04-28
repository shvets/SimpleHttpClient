swift_version = File.new('.swift-version').read

Pod::Spec.new do |s|
  s.name         = "SimpleHttpClient"
  s.version      = "1.0.0"
  s.summary      = "Simple Swift HTTP client"
  s.description  = "Simple Swift HTTP client."

  s.homepage     = "https://github.com/shvets/SimpleHttpClient"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.source = { :git => 'https://github.com/shvets/SimpleHttpClient.git', :tag => s.version }

  s.ios.deployment_target = "10.11"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "10.11"

  s.source_files = "Sources/**/*.swift"
  s.ios.source_files = "Sources/**/*.swift"
  s.tvos.source_files = "Sources/**/*.swift"
  s.osx.source_files = "Sources/**/*.swift"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => swift_version }

  # s.dependency 'Alamofire', '~> 4.7.3'
end
