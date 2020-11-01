#swift_version = File.new('.swift-version').read

Pod::Spec.new do |s|
  s.swift_version = "5.3"
  s.name         = "SimpleHttpClient"
  s.version      = "1.0.5"
  s.summary      = "Simple Swift HTTP client"
  s.description  = "Simple Swift HTTP client."

  s.homepage     = "https://github.com/shvets/SimpleHttpClient"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.source = { :git => 'https://github.com/shvets/SimpleHttpClient.git', :tag => s.version }

  s.ios.deployment_target = "12.3"
  s.tvos.deployment_target = "12.3"
  s.macos.deployment_target = "10.10"

  s.source_files = "Sources/**/*.swift"
  s.ios.source_files = "Sources/**/*.swift"
  s.tvos.source_files = "Sources/**/*.swift"

  s.dependency 'Identity', '~> 0.3.0'
  s.dependency 'Tagging', '~> 0.1.0'
  s.dependency 'Files', '~> 4.1.1'
  s.dependency 'SwiftSoup', '~> 2.3.0'
  s.dependency 'Codextended', '~> 0.3.0'

  #s.pod_target_xcconfig = { 'SWIFT_VERSION' => swift_version }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.3' }
end
