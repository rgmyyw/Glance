fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios release_apple
```
fastlane ios release_apple
```
发布到应用商店苹果商店
### ios commit_app_icon
```
fastlane ios commit_app_icon
```

### ios export_Ad_Hoc_IPA
```
fastlane ios export_Ad_Hoc_IPA
```
Export an ad_hoc file to local
### ios getDevCert
```
fastlane ios getDevCert
```
获取开发证书和配置文件
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
