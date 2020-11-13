
# Readme
本项目主要使用 Swift 语言开发，MVVM 架构


## 所需技术

- [x]  [RxSwift](https://github.com/ReactiveX/RxSwift) && `MVVM`
- [x] `REST API` ([Moya](https://github.com/Moya/Moya), [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper))
- [x] 自定义专场动画 ([Hero](https://github.com/HeroTransitions/Hero))
- [x] `AutoLayout` 布局 ([SnapKit](https://github.com/SnapKit/SnapKit))
- [x] `Logging` ([CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack))

##  工具

- [Brew](https://github.com/Homebrew/brew) - macOS包管理器
- [Fastlane](https://github.com/fastlane/fastlane) - 这是自动构建和发布App
- [JSONExport](https://github.com/Ahmed-Ali/JSONExport) - JSON转模型
- [R.swift](https://github.com/mac-cain13/R.swift) - 在Swift项目中获得强类型、自动完成的资源，如图像、字体和segue
- [Flex](https://github.com/Flipboard/FLEX) - UI调试
- [Postman](https://www.getpostman.com) - 接口调试


## 项目结构

```
├── Application  # Applicatio
├── Common # 通用模块,基类
├── Configs  # app 配置
├── Extensions # 类扩展
├── Managers # 所有Managers
├── Models # model 
├── Modules # 业务模块
├── Networking # 网络请求
├── Resources # 资源
└── Third\ Party # 第三方
10 directories, 1 file
```

## 环境

- `Swift 5.0`
- `Xcode 11.3.1`
- `macOS 10.15.3 (19D76)`

## 编译&运行

在开始之前，你需要做一些事情。
确保你已经从应用商店安装了Xcode。
然后运行下面的命令来安装Xcode的命令行工具(如果还没有的话)

```sh
xcode-select --install
```

安装 [Brew](https://github.com/Homebrew/brew) macOS的包管理器

```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

```sh
brew install cocoapods
```

```sh
pod install --repo-update --verbose
```

```
Pod installation complete! There are xx dependencies from the Podfile and xx total pods installed.
```

打开项目根目录:

```
Glace.xcworkspace
```

```
command + R
```

## 调试
[Flex](https://github.com/Flipboard/FLEX) 这个应用程序集成了Flex调试工具。要启用它，只需在应用程序的任何地方右击即可。还包括调试UI和动画。要使用它，用两个手指向右滑动。重复此操作以禁用。

## 持续集成

[Fastlane](https://fastlane.tools)  自动化常见任务, 自动打包, 证书配置.


## 账号

### Apple ID

- 账号 :  `yanghai@beesplay.cn`
- 密码:   `Aa1234567890`

### onesignal

- 账号 :  `yanghai@beesplay.cn`
- 密码:   `Aa123456qwertAa`

### p12

`beliveforlife432`
`glance0315@!`

##  Other

- 去除控制台coretelephony 打印

```
[Client] Synchronous remote object proxy returned error: Error Domain=NSCocoaErrorDomain Code=4099 "The connection to service on pid 0 named com.apple.commcenter.coretelephony.xpc was invalidated." UserInfo={NSDebugDescription=The connection to service on pid 0 named com.apple.commcenter.coretelephony.xpc was invalidated.}
```

```bash
xcrun simctl spawn booted log config --mode "level:off"  --subsystem com.apple.CoreTelephony
```

### Email 
- 账号:  ``
- 密码:  ``

## 参考

* [RXSwift](https://github.com/ReactiveX/RxSwift) - RxSwift官方
* [RXSwift 相关文档](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/) - RxSwift 中文翻译
