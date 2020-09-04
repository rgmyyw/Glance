# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!


abstract_target 'Glance' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # Pods for Glance
  
  pod 'Moya/RxSwift'
  pod 'Moya-ObjectMapper/RxSwift', '~> 2.0'
  
  # Rx Extensions
  pod 'RxDataSources', '~> 4.0'
  pod 'RxSwiftExt', '~> 5.0'
  pod 'NSObject+Rx', '~> 5.0'
  pod 'RxViewController', '~> 1.0'
  pod 'RxGesture', '~> 3.0'
  pod 'RxOptional', '~> 4.0'
  pod 'RxTheme', '~> 4.0'
  
  pod 'AppAuth' , '~> 1.4.0'
  
  
  # Image
  pod 'Kingfisher', '~> 5.0'
  
  # Date
  pod 'DateToolsSwift', '~> 5.0'
  pod 'SwiftDate', '~> 6.0'
  
  # Tools
  pod 'R.swift', '~> 5.0'
  pod 'SwiftLint', '0.39.2'
  
  # Keychain
  pod 'KeychainAccess', '~> 4.0'
  
  # UI
  pod 'NVActivityIndicatorView', '~> 4.0'
  pod 'ImageSlideshow/Kingfisher', '~> 1.8'
  pod 'DZNEmptyDataSet', '~> 1.0'
  pod 'Hero', :git => 'https://github.com/HeroTransitions/Hero.git', :branch => 'develop'
  pod 'Localize-Swift', '~> 3.0'
  pod 'RAMAnimatedTabBarController', '~> 5.0'
  pod 'AcknowList', '~> 1.8'
  pod 'KafkaRefresh', '~> 1.0'
  pod 'Highlightr', '~> 2.0'
  pod 'DropDown', :git => 'https://github.com/rgmyyw/DropDown.git', :tag => '2.3.18'
  pod 'Toast-Swift', '~> 5.0'
  pod 'HMSegmentedControl', '~> 1.0'
  pod 'FloatingPanel', '~> 1.0'
  pod 'DNSPageView' , '~> 1.5.0'
  pod 'ZLCollectionViewFlowLayout' , '~> 1.4.1'
  pod 'UICollectionView-ARDynamicHeightLayoutCell', :git => 'https://github.com/nilhy/UICollectionView-ARDynamicHeightLayoutCell.git', :branch => 'master', :tag => '1.0.8'
  
#  pod 'UICollectionView-ARDynamicHeightLayoutCell'

  pod 'FDFullscreenPopGesture' , '~> 1.1'
  pod 'FSPagerView' , '~> 0.8.3'
  pod 'SDCAlertView' , '~> 11.1.2'
  pod 'WZLBadge' , '~> 1.2.6'
  pod 'PopupDialog', '~> 1.1'
  pod "Popover" , '~> 1.3.0'
  pod 'WMZPageController', '~> 1.2.5'
  pod 'CWLateralSlide' , '~> 1.6.5'
  pod 'CountryPickerView' , '~> 3.1.2'
  pod 'ZLPhotoBrowser' , '~> 3.2.0'
  pod 'SwipeCellKit' , '~> 2.7.1'
  pod 'XHWebImageAutoSize' , '~> 1.1.2'
  pod 'JXBanner'
  pod 'NewPopMenu', '~> 2.0'
  


   
  
  
  # Keyboard
  pod 'IQKeyboardManagerSwift', '~> 6.0'
  
  # Auto Layout
  pod 'SnapKit', '~> 5.0'
  
  # Code Quality
  pod 'FLEX', '~> 4.0', :configurations => ['Debug']
  pod 'SwifterSwift', '~> 5.0'
  pod 'BonMot', '~> 5.0'
  pod 'Reusable' , '~> 4.1.0'
  
  # Logging
  pod 'CocoaLumberjack/Swift', '~> 3.0'
  
  pod 'CryptoSwift' , '~> 1.3.1'
  
  target 'Glance-D'
  target 'Glance-P'
  target 'Glance-R'
 
end

post_install do |installer|
  # Cocoapods optimization, always clean project after pod updating
  Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
    flag_name = File.basename(script, ".sh") + "-Installation-Flag"
    folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
    file = File.join(folder, flag_name)
    content = File.read(script)
    content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
    File.write(script, content)
  end
  
  # Enable tracing resources
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end
end
