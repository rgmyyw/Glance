//
//  AlertController-Extension.swift
//  
//
//  Created by yanghai on 2020/1/17.
//  Copyright © 2020 fwan. All rights reserved.
//

import SDCAlertView
import RxSwift
import RxCocoa

extension AlertController {
    
    convenience init(customTitle: String? = nil, customMessage: String? = nil, preferredStyle: AlertControllerStyle) {
        
        let attributedTitle: NSAttributedString? = (customTitle == nil) ? nil : NSAttributedString(string: customTitle!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.text(), NSAttributedString.Key.font: UIFont.titleBoldFont(16)])
        let attributedMessage: NSAttributedString? = (customMessage == nil) ? nil : NSAttributedString(string: customMessage!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.text(), NSAttributedString.Key.font: UIFont.titleFont(14)])
        self.init(attributedTitle: attributedTitle, attributedMessage: attributedMessage, preferredStyle: preferredStyle)
        let style = AlertVisualStyle(alertStyle: preferredStyle)
        style.backgroundColor = .white
        style.actionViewSeparatorColor = UIColor(hex:0xE7E8E9)!
        style.normalTextColor = UIColor.primary()
        style.destructiveTextColor = UIColor.textGray()
        ///
        style.alertNormalFont = UIFont.titleBoldFont(16)
        style.alertPreferredFont = UIFont.titleFont(16)
        style.contentPadding = UIEdgeInsets(top: 32, left: 36, bottom: 32, right: 36)
        style.cornerRadius = Configs.BaseDimensions.cornerRadius
        visualStyle = style
    }
}

extension Reactive where Base: AlertAction {

}

extension AlertAction {
    
    func asObservable() -> Observable<Int> {
        let action = PublishSubject<Int>()
        handler = { [weak self]handler in
            if let identity = self?.accessibilityIdentifier?.int {
                action.onNext(identity)
            }
        }
        return action.asObservable()
    }
}


extension AlertController {
    
    public func addActions(_ actions: [AlertAction]) {
        actions.forEach {
            addAction($0)
        }
    }
    
    func asObservable() -> Observable<Int> {
        return Observable.merge(actions.map { $0.asObservable() })
    }
}

@discardableResult
public func showAlert(title: String? = nil, message: String?, optionTitles: String ... , cancel : String = "Cancel" ) -> Observable<Int> {
    let controller = AlertController(customTitle: title, customMessage: message, preferredStyle: .alert)
    let titles = optionTitles
    let actions = titles.enumerated().map { offset, item -> AlertAction in
        let action = AlertAction(title: item, style: .preferred)
        action.accessibilityIdentifier = offset.string
        return action
    }
    let cancel = AlertAction(title: cancel, style: .destructive)
    cancel.accessibilityIdentifier = "-1"
    controller.addAction(cancel)
    controller.addActions(actions)
    controller.present()
    return controller.asObservable()
}
