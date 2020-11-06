//
//  NoticeCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationCellViewModel: CellViewModelProtocol {

    let item : Notification
    let userImageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let userName : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let userState : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    let description : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let time : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let image : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let reaction : BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    let unread : BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
    
    
    required init(item : Notification) {
        self.item = item
        
//        self.userImageURL.accept(item.user?.userImage?.url)
//        self.title.accept(item.title)
//        self.time.accept(item.time?.customizedString())
//        self.image.accept(item.image?.url)
//        self.isRead.accept(item.read)
//        self.online.accept(item.user?.loginStatus ?? false)
    }

    
}
