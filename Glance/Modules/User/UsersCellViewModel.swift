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

    let item : (type : UsersType, model : UserRelation)
    let userName = BehaviorRelay<String?>(value: nil)
    let userImageURL = BehaviorRelay<URL?>(value: nil)
    let ighandle = BehaviorRelay<String?>(value: nil)
    
    let buttonNormalTitle = BehaviorRelay<String?>(value: "")
    let buttonSelectedTitle = BehaviorRelay<String?>(value: "")
    let buttonSelected = BehaviorRelay<Bool>(value: false)
    let buttonTap = PublishSubject<Void>()
    
    required init(item : (type : UsersType, model : UserRelation)) {
        
        self.item = item
        self.userName.accept(item.model.displayName)
        self.userImageURL.accept(item.model.image?.url)
        self.ighandle.accept(item.model.igHandler)
        switch item.type {
        case .blocked:
            self.buttonSelected.accept(item.model.isBlocked)
        case .followers,.following:
            self.buttonSelected.accept(item.model.isFollow)
        }
    }

    
}
