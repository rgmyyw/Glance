//
//  UIView+.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//
import UIKit



extension UIView {

    func makeRoundedCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func makeRoundedCorners() {
        makeRoundedCorners(bounds.size.width / 2)
    }

    func renderAsImage() -> UIImage? {
        var image: UIImage?
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
            image = renderer.image { ctx in
                self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            }
        } else {
            // Fallback on earlier versions
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }

    func blur(style: UIBlurEffect.Style) {
        unBlur()
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        insertSubview(blurEffectView, at: 0)
        blurEffectView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }

    func unBlur() {
        subviews.filter { (view) -> Bool in
            view as? UIVisualEffectView != nil
        }.forEach { (view) in
            view.removeFromSuperview()
        }
    }
    
    
    
}

extension UIView {
    
    func searchVisualEffectsSubview() -> UIVisualEffectView? {
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        } else {
            for subview in subviews {
                if let found = subview.searchVisualEffectsSubview() {
                    return found
                }
            }
        }
        return nil
    }
    
    /// This is the function to get subViews of a view of a particular type
    /// https://stackoverflow.com/a/45297466/5321670
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /// This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T
    /// https://stackoverflow.com/a/45297466/5321670
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}


public extension UIView {

    
    struct UIViewPrivateKeys {
        static var enableDebugKey : String = "enableDebugKey"
    }
    
    /// 递归当前view并做一些事情
    /// - Parameters:
    ///   - current: 是否包含
    ///   - handle: 对这些做什么
    func recursive( _ current : Bool = false, _ handle : (UIView) -> (Void)) {
        if current { handle(self) }
        for i in self.subviews {
            handle(i)
            i.recursive(false, handle)
        }
    }
}

public extension UIView {
    
    /// 开启调试模式,为view 以及子viewz 自动设置随机颜色!
    var enableDebug : Bool {
        set{
            objc_setAssociatedObject(self, &UIViewPrivateKeys.enableDebugKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if newValue == true {
                self.recursive(true) { $0.backgroundColor = UIColor.random() }
            } else {
                self.recursive(true) { $0.backgroundColor = .white }
            }
        }
        get{
            return objc_getAssociatedObject(self, &UIViewPrivateKeys.enableDebugKey) as? Bool ?? false
        }
    }
}
