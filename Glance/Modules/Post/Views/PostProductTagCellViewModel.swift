//
//  PostProductTagCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

enum PostProductTagStyle {
    case custom
    case system
    
    
    
    enum PostProductTagStyleAction {
        case delete
        case state(Bool)
    }
    
    var normalBackgroundColor : UIColor {
        switch self {
        case .custom:
            return UIColor.primary()
        case .system:
            return UIColor(hex: 0xDDDDDD)!
        }
    }
    
    var selectedBackgroundColor : UIColor {
        return PostProductTagStyle.custom.normalBackgroundColor
    }

    var normalTitleColor : UIColor {
        switch self {
        case .custom:
            return .white
        case .system:
            return UIColor.text()
        }

    }
    
    var selectedTitleColor : UIColor {
        return PostProductTagStyle.custom.normalTitleColor
    }
    
    var actionButtonNormalTitle : String {
        switch self {
        case .custom:
            return ""
        case .system:
            return "+"
        }
    }
    
    var actionButtonSelectedTitle : String {
        switch self {
        case .custom:
            return "x"
        case .system:
            return "-"
        }
    }
    
    var actionButtonTitleNormalColor : UIColor {
        switch self {
        case .custom:
            return UIColor.white
        case .system:
            return UIColor.text()
        }

    }

    var actionButtonTitleSelectedColor : UIColor {
        return .white
    }

}


class PostProductTagCellViewModel: CellViewModelProtocol  {

    let item : String
  
    let title = BehaviorRelay<String?>(value: nil)
    let selected = BehaviorRelay<Bool>(value: false)
    
    
    let style = BehaviorRelay<PostProductTagStyle?>(value: nil)
    let action = PublishSubject<PostProductTagStyle.PostProductTagStyleAction>()
    
    
    required init(item : String) {
        self.item = item
        self.title.accept(item)
        
    }

}
