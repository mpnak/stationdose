source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "8.0"
use_frameworks!

target "Stationdose" do 

pod 'Alamofire', '~> 3.0'
pod 'ChameleonFramework', '~> 2.0'
pod 'ObjectMapper', '1.2'
pod 'AlamofireObjectMapper', '~> 2.0'
pod 'NVActivityIndicatorView', '2.6'
pod 'MGSwipeTableCell', '~> 1.5'
pod 'AlamofireImage', '~> 2.0'
#pod 'netfox', '~> 1.7'
pod 'Branch', '~> 0.11'
pod 'Fabric'
pod 'Crashlytics'
pod 'Charts', '2.3.0'
#pod 'HanekeSwift'
pod 'HanekeSwift', :git => 'https://github.com/cannyboy/HanekeSwift.git'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
