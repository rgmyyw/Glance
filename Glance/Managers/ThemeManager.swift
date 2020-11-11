import UIKit
import RxSwift
import RxCocoa
import RxTheme
import RAMAnimatedTabBarController


let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .lightContent)

let themeService = ThemeType.service(initial: ThemeType.currentTheme())

protocol Theme {
    
    var global : UIColor  { get }
    
    /// 主色调: 红色
    var primary: UIColor { get }
    ///
    var secondary: UIColor { get }
    
    /// 一级信息，标题，主内容文字,黑色 0x222324
    var text: UIColor { get }
    
    /// 二级信息,标题: 灰色 0x999EA3
    var textGray: UIColor { get }
    
    var textSecondary: UIColor { get }
    
    /// 分割线，按钮边缘，置灰按钮等 页面底部背景
    var separator: UIColor { get }
    /// 页面底部背景
    var background: UIColor { get }
    
    
    var statusBarStyle: UIStatusBarStyle { get }
    var barStyle: UIBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var blurStyle: UIBlurEffect.Style { get }
    
    

    init(colorTheme: ColorTheme)
}

struct LightTheme: Theme {
      
    var global: UIColor = .white
    let primary = UIColor(hex: 0xFF8159)!
    var secondary = UIColor(hex:0x2D4CA9)!
    let separator = UIColor(hex:0xe4ebf2)!
    let text = UIColor(hex:0x333333)!
    let textGray = UIColor(hex:0x999999)!
    let textSecondary = UIColor(hex:0x515457)!
    
    let background = UIColor.white
    let statusBarStyle = UIStatusBarStyle.default
    let barStyle = UIBarStyle.default
    let keyboardAppearance = UIKeyboardAppearance.light
    let blurStyle = UIBlurEffect.Style.extraLight

    init(colorTheme: ColorTheme) {
        secondary = colorTheme.color
    }
}

enum ColorTheme: Int {
    
    case primary

    static let allValues = [primary]

    var color: UIColor {
        switch self {
        case .primary: return UIColor(hex: 0xFF8159)!
        }
    }

    var title: String {
        switch self {
        case .primary: return "primary"
        }
    }
}

/// 主题类型
enum ThemeType: ThemeProvider {
    
    case light(color: ColorTheme)
    
    /// 关联主题对象
    var associatedObject: Theme {
        switch self {
        case .light(let color): return LightTheme(colorTheme: color)
        }
    }

    /// 当前是否为暗黑模式
    var isDark: Bool {
        switch self {
        default: return false
        }
    }

    func toggled() -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light(let color): theme = ThemeType.light(color: color)
        }
        theme.save()
        return theme
    }

    func withColor(color: ColorTheme) -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light: theme = ThemeType.light(color: color)
        }
        theme.save()
        return theme
    }
}

extension ThemeType {
    
    /// 获取当前的主题
    static func currentTheme() -> ThemeType {
        let theme =  ThemeType.light(color: ColorTheme.primary)
        theme.save()
        return theme
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(self.isDark, forKey: "IsDarkKey")
        switch self {
        case .light(let color): defaults.set(color.rawValue, forKey: "ThemeKey")
        }
    }
}

// MARK: - UIView
extension Reactive where Base: UIView {

    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.backgroundColor = attr
        }
    }
}

// MARK: - UITextField
extension Reactive where Base: UITextField {

    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.borderColor = attr
        }
    }

    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            if let color = attr {
                view.setPlaceHolderTextColor(color)
            }
        }
    }
}

// MARK: - UITableView
extension Reactive where Base: UITableView {

    var separatorColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.separatorColor = attr
        }
    }
}

// MARK: - RAMAnimatedTabBarItem
extension Reactive where Base: RAMAnimatedTabBarItem {

    var iconColor: Binder<UIColor> {
        return Binder(self.base) { view, attr in
            view.iconColor = attr
            view.deselectAnimation()
        }
    }

    var textColor: Binder<UIColor> {
        return Binder(self.base) { view, attr in
            view.textColor = attr
            view.deselectAnimation()
        }
    }
}

// MARK: - RAMItemAnimation
extension Reactive where Base: RAMItemAnimation {

    var iconSelectedColor: Binder<UIColor> {
        return Binder(self.base) { view, attr in
            view.iconSelectedColor = attr
        }
    }

    var textSelectedColor: Binder<UIColor> {
        return Binder(self.base) { view, attr in
            view.textSelectedColor = attr
        }
    }
}

// MARK: - UINavigationBar
extension Reactive where Base: UINavigationBar {

    @available(iOS 11.0, *)
    var largeTitleTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        return Binder(self.base) { view, attr in
            view.largeTitleTextAttributes = attr
        }
    }
}

// MARK: - UIApplication
extension Reactive where Base: UIApplication {

    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { view, attr in
            globalStatusBarStyle.accept(attr)
        }
    }
}




// MARK: - UISwitch
public extension Reactive where Base: UISwitch {
    
    var onTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.onTintColor = attr
        }
    }

    var thumbTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.thumbTintColor = attr
        }
    }
}
