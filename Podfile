platform :ios, '8.0'

use_frameworks!


target 'AppYourGoal360' do

inhibit_all_warnings!

pod 'Parse'
pod 'SVProgressHUD'
pod 'ReachabilitySwift'
pod 'TestFairy'
pod 'IQKeyboardManagerSwift'
pod 'FBSDKLoginKit'
pod 'FBSDKCoreKit'
pod 'Kingfisher', '~> 1.6'
pod 'DKImagePickerController'
pod 'Alamofire', '~> 3.0'
end

target 'AppYourGoal360Tests' do

end

post_install do |installer|
    app_plist = “AppYourGoal360/Info.plist"
    plist_buddy = "/usr/libexec/PlistBuddy"

    version = `#{plist_buddy} -c "Print CFBundleShortVersionString" "#{app_plist}"`.strip

    puts "Updating CocoaPods frameworks' version numbers to #{version}"

    installer.pods_project.targets.each do |target|  
        `#{plist_buddy} -c "Set CFBundleShortVersionString #{version}" "Pods/Target Support Files/#{target}/Info.plist"`  
    end  
end

