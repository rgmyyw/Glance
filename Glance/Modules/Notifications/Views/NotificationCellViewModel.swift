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
    let userImageURL = BehaviorRelay<URL?>(value: nil)
    let title = BehaviorRelay<String?>(value: nil)
    let time = BehaviorRelay<String?>(value: nil)
    let image = BehaviorRelay<URL?>(value: nil)
    let isRead = BehaviorRelay<Bool>(value: false)
    let typeImage = BehaviorRelay<UIImage?>(value: nil)
    let online = BehaviorRelay<Bool>(value: false)
    
    
    required init(item : Notification) {
        
        self.item = item
        self.userImageURL.accept(item.user?.userImage?.url)
        self.title.accept(item.title)
        self.time.accept(item.time?.customizedString())
        self.image.accept(item.image?.url)
        self.isRead.accept(item.read)
        self.online.accept(item.user?.loginStatus ?? false)
    }

    
}
