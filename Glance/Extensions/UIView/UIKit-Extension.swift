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


// MARK: - UIViewController
extension UIViewController {
    
    func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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


extension  UITextField {
    
    
    func limitCharacter(number : Int) {
        rx.text.orEmpty.map { ($0, $0.count > number) }
            .subscribe(onNext: { [weak self](text, valid) in
                if valid , number > 0 {
                    self?.text = text[0..<number]
                }
                
            }).disposed(by: rx.disposeBag)
    }
    
}



extension Reactive where Base: UITextField {
    
    
    public var limitCharacterNumber: Binder<UInt8> {
        return Binder<UInt8>(self.base) { textField, number in
            let valid = textField.rx.text.orEmpty.map { $0.count < number }
            valid.subscribe(onNext: { v in
                
            }).disposed(by: self.disposeBag)
        }
    }
    
}



extension UILabel {
    
    func line(maxWidth : CGFloat = UIScreen.main.bounds.width,
              maxHeight : CGFloat = CGFloat(MAXFLOAT)) -> Int {
        guard let text = self.text  else { return 1 }
        return text.line(attributes: [.font : font!], maxWidth: maxWidth, maxHeight: maxHeight)
    }

}

extension String {
    
    /// 计算当前文字需要占多少行
    /// - Parameters:
    ///   - font: 字体
    ///   - maxWidth: 最大宽度
    ///   - maxHeight: 最大高度
    func line(by font : UIFont,
              maxWidth : CGFloat = UIScreen.main.bounds.width,
              maxHeight : CGFloat = CGFloat(MAXFLOAT)) -> Int {
        
        return line(attributes: [.font: font], maxWidth: maxWidth, maxHeight: maxHeight)
    }


    /// 计算当前文字需要占多少行
    /// - Parameters:
    ///   - attributes: 必传属性, 一般情况传字体大小,但是有些label需要计算行间距
    ///   - maxWidth: 最大宽度
    ///   - maxHeight: 最大高度
    func line(attributes: [NSAttributedString.Key : Any],
              maxWidth : CGFloat = UIScreen.main.bounds.width,
              maxHeight : CGFloat = CGFloat(MAXFLOAT)) -> Int {
        let text = self as NSString
        let maxSize = CGSize(width: maxWidth, height: CGFloat(MAXFLOAT))
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).height
        let font = attributes[.font] as? UIFont
        let lineHeight = font?.lineHeight ?? 1
        return Int(ceil(textHeight / lineHeight))
    }
}
