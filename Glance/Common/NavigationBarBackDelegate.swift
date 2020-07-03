//
//  NavigationBarBackDelegate.swift
//  
//
//  Created by yanghai on 2020/4/1.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit


//@objc protocol NavigationBarBackDelegate  {
//    @objc optional func shouldPopOnBackButtonPress() -> Bool
//}
//
//extension UIViewController: NavigationBarBackDelegate {
//    
//    func shouldPopOnBackButtonPress() -> Bool {
//        return true
//    }
//}
//
//extension UINavigationController: UINavigationBarDelegate {
//    
//    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
//        
//        var shouldPop = true
//        let controller  = self.topViewController
//        
//        if let should = controller?.shouldPopOnBackButtonPress() {
//            shouldPop = should
//        }
//        
//        if (shouldPop == true) {
//            return true
//            
//        } else {
//            // 让系统backIndicator 按钮透明度恢复为1
//            for subview in navigationBar.subviews {
//                if (0.0 < subview.alpha && subview.alpha < 1.0) {
//                    UIView.animate(withDuration: 0.25, animations: {
//                        subview.alpha = 1.0
//                    })
//                }
//            }
//            return false
//        }
//    }
//}
