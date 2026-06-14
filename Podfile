platform :ios, '15.0'

target 'FacesofnaijaiOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  # Pods for News_Feed
  
  #  pod 'PINCache', :git => 'https://github.com/pinterest/PINCache', :branch => 'master'
  #  pod 'PINRemoteImage', :git => 'https://github.com/pinterest/PINRemoteImage', :branch => 'master'
  pod 'Alamofire','~> 5.2'
  pod 'AlamofireImage'
  pod 'Kingfisher', '~>5.15.7'
  pod 'ZKProgressHUD'
  pod 'SDWebImage'
  pod 'MobilePlayer'
  pod 'Player'
  pod 'FBSDKCoreKit'
  pod 'R.swift'
  pod 'FBSDKLoginKit'
  pod 'IQKeyboardManager' #iOS8 and later
  pod 'GoogleSignIn', '5.0.0'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'YouTubePlayer'
  pod 'ActiveLabel'
  pod 'PaginatedTableView'
  pod 'Cosmos', '~> 20.0'
  pod 'Toast-Swift'
  pod 'CropViewController'
  pod 'XLPagerTabStrip'
  pod 'ImageSlideshow'
  pod 'ImageSlideshow/Kingfisher'
  pod 'NVActivityIndicatorView'
  pod 'TTRangeSlider'
  pod 'MMPlayerView'
  pod 'ActionSheetPicker-3.0'
  pod 'FontAwesome.swift'
  pod 'FittedSheets'
  pod 'VersaPlayer'
  pod "LinearProgressBar"
  pod 'Google-Mobile-Ads-SDK'
  pod 'Braintree'
  pod 'BraintreeDropIn'
  pod 'iRecordView'
  pod 'AgoraRtcEngine_iOS'
  pod 'Paystack'
  pod 'CircleBar'

  #    pod 'Giphy'
  target 'FacesofnaijaiOSTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'FacesofnaijaiOSUITests' do
    # Pods for FacesofnaijaiOS
  end
  
end

target 'OneSignalNotificationServiceExtension' do
  use_frameworks!
  pod 'OneSignal', '>= 2.11.2', '< 3.0'
end
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  end
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      if config.build_settings['LIBRARY_SEARCH_PATHS'] != nil
        config.build_settings['LIBRARY_SEARCH_PATHS'] = config.build_settings['LIBRARY_SEARCH_PATHS'].map { |path|
          path.gsub('DT_TOOLCHAIN_DIR', 'TOOLCHAIN_DIR')
        }
      end
      if config.build_settings['FRAMEWORK_SEARCH_PATHS'] != nil
        config.build_settings['FRAMEWORK_SEARCH_PATHS'] = config.build_settings['FRAMEWORK_SEARCH_PATHS'].map { |path|
          path.gsub('DT_TOOLCHAIN_DIR', 'TOOLCHAIN_DIR')
        }
      end
    end
  end
end

