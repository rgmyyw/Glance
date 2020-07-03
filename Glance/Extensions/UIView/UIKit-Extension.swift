//
//  UIKit-Extension.swift
//  
//
//  Created by yanghai on 2020/1/14.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


// MARK: - UIApplication
extension UIApplication {
    
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

// MARK: - [UIView]
extension Array where Element : UIView {
    
    func tapGesture() -> Observable<Int> {
        
        enumerated().forEach { index, item in
            item.tag = index
            item.isUserInteractionEnabled = true
        }
        
        let viewTaps = compactMap { $0.rx.tapGesture().when(.recognized).map { $0.view }.filterNil().map { $0.tag} }
        return Observable.merge(viewTaps)
    }
}


