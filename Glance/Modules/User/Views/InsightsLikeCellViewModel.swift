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

class InsightsLikeCellViewModel: CellViewModelProtocol {

    let item : User
    let userName = BehaviorRelay<String?>(value: nil)
    let userImageURL = BehaviorRelay<URL?>(value: nil)
    let ighandle = BehaviorRelay<String?>(value: nil)
    
    let buttonNormalTitle = BehaviorRelay<String?>(value: "+ Follow")
    let buttonSelectedTitle = BehaviorRelay<String?>(value: "Following")
    let isFollow = BehaviorRelay<Bool>(value: false)
    let buttonTap = PublishSubject<Void>()
    
    required init(item : User) {

        self.item = item
        self.userName.accept(item.displayName)
        self.userImageURL.accept(item.userImage?.url)
        self.ighandle.accept(item.igHandler)
        self.isFollow.accept(item.isFollow)
    }

    
}
