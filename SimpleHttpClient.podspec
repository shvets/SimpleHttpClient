Pod::Spec.new do |s|
  s.name         = "SimpleHttpClient"
  s.version      = "1.0.0"
  s.summary      = "Simple Swift HTTP client"
  s.description  = "Simple Swift HTTP client."

  s.homepage     = "https://github.com/shvets/SimpleHttpClient"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.source = { :git => 'https://github.com/shvets/SimpleHttpClient.git', :tag => s.version }

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "10.0"

  s.source_files = "Sources/**/*.swift"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5' }
end
