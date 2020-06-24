
platform :ios, '12.1'

target 'Lynked' do

  use_frameworks!

  # Pods for Lynked

  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Branch'

  pod 'Firebase/Core'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Performance'
  pod 'Firebase/Analytics'
  pod 'Firebase/Database'


  pod 'Kingfisher'
  #pod 'SCPinViewController'
  pod 'mailgun'
  pod 'UITextView+Placeholder'
  pod 'DZNEmptyDataSet'
  pod 'MBProgressHUD'


end

target 'Lynked Widget' do
use_frameworks!

  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Performance'
  pod 'Kingfisher'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Database'
  pod 'Firebase/Performance'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
    end
  end
end
