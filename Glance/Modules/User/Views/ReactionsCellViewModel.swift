//
//  ReactionsCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ReactionsCellViewModel: CellViewModelProtocol {

    let item : Reaction
    let userName = BehaviorRelay<String?>(value: nil)
    let userImageURL = BehaviorRelay<URL?>(value: nil)
    let ighandle = BehaviorRelay<String?>(value: nil)
    
    let buttonNormalTitle = BehaviorRelay<String?>(value: "+ Follow")
    let buttonSelectedTitle = BehaviorRelay<String?>(value: "Following")
    let isFollow = BehaviorRelay<Bool>(value: false)
    let buttonTap = PublishSubject<Void>()
    
    required init(item : Reaction) {
        
        self.item = item
        self.userName.accept(item.displayName)
        self.userImageURL.accept(item.image?.url)
        self.ighandle.accept(item.igHandler)
        self.isFollow.accept(item.isFollow)
    }

    
}
