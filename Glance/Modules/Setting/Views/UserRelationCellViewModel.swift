//
//  BlockedCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserRelationCellViewModel: CellViewModelProtocol {

    let item : (UserRelationType,UserRelation)
    let userName = BehaviorRelay<String?>(value: nil)
    let userImageURL = BehaviorRelay<URL?>(value: nil)
    let ighandle = BehaviorRelay<String?>(value: nil)
    
    let buttonNormalTitle = BehaviorRelay<String?>(value: "")
    let buttonSelectedTitle = BehaviorRelay<String?>(value: "")
    let isFollow = BehaviorRelay<Bool>(value: false)
    let buttonTap = PublishSubject<Void>()
    
    required init(item : (UserRelationType,UserRelation)) {
        
        self.item = item
        self.userName.accept(item.1.displayName)
        self.userImageURL.accept(item.1.image?.url)
        self.ighandle.accept(item.1.igHandler)
        self.isFollow.accept(item.0 == .blocked ? item.1.isBlocked : item.1.isFollow)
    }

    
}
