# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

abstract_target 'Base' do

    # push
    pod 'OneSignal' , '~> 2.15.4'
        
    # Tools
    pod 'R.swift', '~> 5.3.0'
    pod 'SwiftLint', '0.39.2'
    
    
    target 'NotificationServiceExtension'
    abstract_target 'Glance' do
      # Pods for Glance
      pod 'Moya', '~> 14.0.0'
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
      pod 'Kingfisher', '~> 5.14.1'
      
      # Date
      pod 'DateToolsSwift', '~> 5.0.0'
      pod 'SwiftDate', '~> 6.2.0'
      
      
      # Keychain
      pod 'KeychainAccess', '~> 4.2.1'
      
      # UI
      pod 'NVActivityIndicatorView', '~> 4.0'
      pod 'ImageSlideshow/Kingfisher', '~> 1.8'
      pod 'DZNEmptyDataSet', '~> 1.8.1'
      pod 'Hero', :git => 'https://github.com/HeroTransitions/Hero.git', :branch => 'develop'
      pod 'Localize-Swift', '~> 3.1.0'
      pod 'RAMAnimatedTabBarController', '~> 5.0'
      pod 'AcknowList', '~> 1.9.5'
      pod 'Highlightr', '~> 2.0'
      pod 'DropDown', :git => 'https://github.com/huangwenkang123/DropDown.git', :tag => '2.3.18'
      pod 'Toast-Swift', '~> 5.0'
      pod 'HMSegmentedControl', '~> 1.5.6'
      pod 'FloatingPanel', '~> 1.7.6'
      pod 'DNSPageView' , '~> 1.5.0'
      pod 'ZLCollectionViewFlowLayout' , '~> 1.4.3'
      pod 'UICollectionView-ARDynamicHeightLayoutCell', :git => 'https://github.com/huangwenkang123/UICollectionView-ARDynamicHeightLayoutCell.git', :tag => '1.0.8'
      pod 'ChameleonFramework/Swift', :git => 'https://github.com/wowansm/Chameleon', :branch => 'swift5'
      pod 'FDFullscreenPopGesture' , '~> 1.1'
      pod 'FSPagerView' , '~> 0.8.3'
      pod 'SDCAlertView' , '~> 11.1.2'
      pod 'WZLBadge' , :git => 'https://github.com/BeeModule/WZLBadge.git' ,:tag => '1.2.6'
      pod 'PopupDialog', '~> 1.1'
      pod "Popover" , '~> 1.3.0'
      pod 'WMZPageController', '~> 1.3.2'
      pod 'CWLateralSlide' , '~> 1.6.5'
      pod 'CountryPickerView' , '~> 3.1.3'
      pod 'ZLPhotoBrowser' , '~> 3.2.0'
      pod 'SwipeCellKit', :git => 'https://github.com/huangwenkang123/SwipeCellKit.git', :tag => '2.7.4'
      pod 'JXBanner', '~> 0.3.2'
      pod 'JXPageControl', '~> 0.1.3'
      pod 'NewPopMenu', '~> 2.0'
      pod 'MJRefresh' , '~> 3.5.0'


      # Keyboard
      pod 'IQKeyboardManagerSwift', '~> 6.5.6'
      
      # Auto Layout
      pod 'SnapKit', '~> 5.0.1'
      
      # Code Quality
      pod 'FLEX', '~> 4.1.1', :configurations => ['Debug']
      pod 'Reveal-SDK', '~> 24', :configurations => ['Debug']
      pod 'SwifterSwift', '~> 5.0'
      pod 'BonMot', '~> 5.5.1'
      pod 'Reusable' , '~> 4.1.0'
      
      # Logging
      pod 'CocoaLumberjack/Swift', '~> 3.6.2'
      pod 'CryptoSwift' , '~> 1.3.2'
      
      # Permissions
      pod 'SPPermissions', '~> 5.4',:subspecs => ['Camera','PhotoLibrary','Notification']
      
      target 'Glance-D'
      target 'Glance-P'
      target 'Glance-R'
     
    end

    
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
