use_frameworks!

target 'Exercise_RxSwift' do
    platform :ios, '11.0'

    pod 'RxSwift', '~> 4.0'
    pod 'RxSwiftExt'

    pod 'RxCocoa', '~> 4.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
  end

  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end