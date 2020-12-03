#
# Be sure to run `pod lib lint SolanaSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SolanaSwift'
  s.version          = '0.2.0'
  s.summary          = 'A client for Solana written in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Solana-blockchain client, written in pure swift, which supports keypair generation, networking, creating and signing transactions
                       DESC

  s.homepage         = 'https://github.com/p2p-org/solana-swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chung Tran' => 'chung.t@p2p.org' }
  s.source           = { :git => 'https://github.com/p2p-org/solana-swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'SolanaSwift/Classes/**/*'
  s.swift_version = '5.0'
  
  # s.resource_bundles = {
  #   'SolanaSwift' => ['SolanaSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RxAlamofire'
  s.dependency 'TweetNacl'
  s.dependency 'CryptoSwift'
  s.dependency "ASKSecp256k1"
  s.dependency 'Starscream'
  s.dependency 'RxCocoa'
end
