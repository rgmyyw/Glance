//
//  UsersCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UsersCellViewModel: CellViewModelProtocol {

    let item : (type : UsersType, model : User)
    let userName = BehaviorRelay<String?>(value: nil)
    let userImageURL = BehaviorRelay<URL?>(value: nil)
    let ighandle = BehaviorRelay<String?>(value: nil)
    
    let buttonNormalTitle = BehaviorRelay<String?>(value: "")
    let buttonSelectedTitle = BehaviorRelay<String?>(value: "")
    let buttonSelected = BehaviorRelay<Bool>(value: false)
    let buttonTap = PublishSubject<Void>()
    let buttonHidden = BehaviorRelay<Bool>(value: false)
    
    required init(item : (type : UsersType, model : User)) {
        
        self.item = item
        self.userName.accept(item.model.displayName)
        self.userImageURL.accept(item.model.userImage?.url)
        self.ighandle.accept(item.model.igHandler)
        self.buttonHidden.accept(item.model.userId == user.value?.userId)
        self.buttonNormalTitle.accept(item.type.cellButtonNormalTitle)
        self.buttonSelectedTitle.accept(item.type.cellButtonSelectedTitle)
        
        switch item.type {
        case .blocked:
            self.buttonSelected.accept(item.model.isBlocked)
        case .followers,.following,.reactions:
            self.buttonSelected.accept(item.model.isFollow)
        
        }
    }

    
}
