//
//  GlancePopMenuAction.swift
//  Glance
//
//  Created by yanghai on 2020/8/28.
//  Copyright © 2020 yanghai. All rights reserved.
//

import PopMenu

class PopMenu {
    
    // MARK: - Properties
    
    /// Default manager singleton.
    public static let share = PopMenu()
    
    /// Reference to the pop menu view controller.
    private var popMenu: PopMenuViewController!
    
    /// Reference to the pop menu delegate instance.
    public weak var popMenuDelegate: PopMenuViewControllerDelegate? {
        didSet {
            popMenu?.delegate = popMenuDelegate
        }
    }
    
    /// Determines whether to dismiss menu after an action is selected.
    public var popMenuShouldDismissOnSelection: Bool = true
    
    /// The dismissal handler for pop menu.
    public var popMenuDidDismiss: ((Bool) -> Void)?
    
    /// Determines whether to use haptics for menu selection.
    public var popMenuShouldEnableHaptics: Bool = true
    
    /// Appearance for passing on to pop menu.
    public let popMenuAppearance: PopMenuAppearance
    
    /// Every action item about to be displayed.
    public var actions: [PopMenuAction] = []
    
    // MARK: - Important Methods
    
    /// Configure and load pop menu view controller.
    private func prepareViewController(sourceView: AnyObject?) {
        popMenu = PopMenuViewController(sourceView: sourceView, actions: actions)

        popMenu.delegate = popMenuDelegate
        popMenu.appearance = popMenuAppearance
        popMenu.containerView.addShadow(offset: .init(width: 0, height: 1), opacity: 0.5, radius: 0)
        popMenu.shouldDismissOnSelection = popMenuShouldDismissOnSelection
        popMenu.didDismiss = popMenuDidDismiss
        popMenu.shouldEnableHaptics = popMenuShouldEnableHaptics
        popMenu.appearance.popMenuColor.backgroundColor = PopMenuActionBackgroundColor.solid(fill: UIColor.white)
        popMenu.appearance.popMenuColor.actionColor = .tint(UIColor.text())
    }
    
    /// Initializer with appearance.
    public init(appearance: PopMenuAppearance = PopMenuManager.default.popMenuAppearance) {
        popMenuAppearance = appearance
    }
    
    /// Pass a new action to pop menu.
    public func addAction(_ action: PopMenuAction) {
        if let popMenu = popMenu {
            popMenu.addAction(action)
        } else {
            actions.append(action)
        }
    }
    
}

// MARK: - Presentations

extension PopMenu {
    
    public func present(sourceView: AnyObject? = nil, on viewController: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        prepareViewController(sourceView: sourceView)
        
        guard let popMenu = popMenu else { print("Pop Menu has not been initialized yet."); return }
        
        if let presentOn = viewController {
            presentOn.present(popMenu, animated: animated, completion: completion)
        } else {
            if let topViewController = PopMenu.getTopViewControllerInWindow() {
                topViewController.present(popMenu, animated: animated, completion: completion)
            }
        }
    }
    
}

// MARK: - Helper Methods

extension PopMenu {
    
    /// Get top view controller in window.
    fileprivate class func getTopViewControllerInWindow() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow else { return nil }
        
        return topViewControllerWithRootViewController(rootViewController: window.rootViewController)
    }
    
    /// Get top view controller.
    fileprivate static func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController! {
        // Tab Bar View Controller
        if rootViewController is UITabBarController {
            let tabbarController =  rootViewController as! UITabBarController
            
            return topViewControllerWithRootViewController(rootViewController: tabbarController.selectedViewController)
        }
        // Navigation ViewController
        if rootViewController is UINavigationController {
            let navigationController = rootViewController as! UINavigationController
            
            return topViewControllerWithRootViewController(rootViewController: navigationController.visibleViewController)
        }
        // Presented View Controller
        if let controller = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(rootViewController: controller)
        } else {
            return rootViewController
        }
    }
    
}
