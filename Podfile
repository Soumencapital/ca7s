# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CA7S' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  
  use_frameworks!

  # Pods for CA7S
pod 'IQKeyboardManagerSwift', '~> 5.0'
pod 'Alamofire-SwiftyJSON', '~> 3.0'
pod 'Localize-Swift', '~> 2.0'
pod 'SVProgressHUD'
pod 'SDWebImage', '~> 4.0'
pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'PopoverKit', '~> 0.2.0'
pod 'PullToRefresher', '~> 3.1'
pod 'SwiftGifOrigin', '~> 1.7.0'
pod 'ImageSlideshow','1.8.0'
pod 'ObjectMapper', '~> 3.4'
pod 'ImageSlideshow/Alamofire'
pod 'iCarousel'
pod 'TTGTagCollectionView'
pod 'YXWaveView'
pod 'Gallery'
pod 'ActionSheetPicker-3.0'



post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
  installer.pods_project.targets.each do |target|
    if ['Gallery'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
    if ['ImageSlideshow'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
    if ['ObjectMapper'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
 
end
