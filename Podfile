# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'netradio player' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for netradio player
  pod 'Toast-Swift', '~> 4.0.0'
  pod 'XLPagerTabStrip', :git => 'https://github.com/xmartlabs/XLPagerTabStrip.git', :branch => 'master'
  pod 'ReachabilitySwift'
  pod 'FontAwesome.swift'
  pod 'SideMenu'

  target 'netradio playerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'netradio playerUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do | installer |
  require 'fileutils'

  FileUtils.cp_r('Pods/Target Support Files/Pods-netradio player/Pods-netradio player-Acknowledgements.plist', 'netradio player/Settings.bundle/Acknowledgements.plist', :remove_destination => true)

end
