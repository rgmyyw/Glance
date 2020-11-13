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
        
    let following : BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let theme : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let themeImages : BehaviorRelay<[Observable<URL?>]> = BehaviorRelay(value: [])
    
    
    let follow : PublishSubject<Void> = PublishSubject()
    let delete : PublishSubject<Void> = PublishSubject()
    let userDetail : PublishSubject<Void> = PublishSubject()
    let themeDetail : PublishSubject<Int> = PublishSubject()
    let postDetail : PublishSubject<Void> = PublishSubject()

    
    required init(item : Notification) {
        self.item = item
        
        self.userImageURL.accept(item.user?.userImage?.url)
        self.userName.accept(item.user?.username)
        self.following.accept(item.user?.isFollow ?? false)
        self.time.accept(item.time?.customizedString())
        self.image.accept(item.image?.url)
        self.unread.accept(item.read)
        self.reaction.accept(item.reaction?.image)
        self.theme.accept(item.theme)
        self.description.accept(item.description)
        self.themeImages.accept(item.themeImages.map { Observable.just($0.url)})
        
    }
    
    

    func makeItemType() -> NotificationSectionItem {
        
        guard let type = item.type else { fatalError() }
        
        switch type {
        case .following:
            return .following(viewModel: self)
        case .liked:
            return .liked(viewModel: self)
        case .mightLike:
            return .mightLike(viewModel: self)
        case .reacted:
            return .reacted(viewModel: self)
        case .recommended:
            return .recommended(viewModel: self)
        case .system:
            return .system(viewModel: self)
        case .theme:
            return .theme(viewModel: self)
        }
    }

    
}
