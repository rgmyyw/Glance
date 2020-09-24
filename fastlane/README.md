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
### ios export_IPA
```
fastlane ios export_IPA
```
导出发布版iPA
### ios export_Ad_Hoc_IPA
```
fastlane ios export_Ad_Hoc_IPA
```
导出开发环境iPA
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
