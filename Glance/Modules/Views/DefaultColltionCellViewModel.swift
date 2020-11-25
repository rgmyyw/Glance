//
//  DefaultColltionCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DefaultColltionCellViewModel: CellViewModelProtocol, CollectionCellImageHeightCalculateable {

    let item: DefaultColltionItem
    let imageURL: BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let userName: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let displayName: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let userHeadImageURL: BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let time: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let recommended: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let reactionImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    let userOnline: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let saved: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let images: BehaviorRelay<[Observable<URL?>]> = BehaviorRelay(value: [])
    let followed: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let memu: BehaviorRelay<[DefaultColltionMemu]> = BehaviorRelay(value: [])
    let memuHidden: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let liked: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let selected: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    /// extension
    let recommendButtonHidden: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    /// actions
    let more: PublishSubject<Void> = PublishSubject()
    let save: PublishSubject<Void> = PublishSubject()
    let recommend: PublishSubject<Void> = PublishSubject()
    let userDetail: PublishSubject<Void> = PublishSubject()
    let reaction: PublishSubject<UIView> = PublishSubject()
    let follow: PublishSubject<Void> = PublishSubject()

    /// memu actions
    let like: PublishSubject<Void> = PublishSubject()
    let share: PublishSubject<Void> = PublishSubject()
    let delete: PublishSubject<Void> = PublishSubject()
    let report: PublishSubject<Void> = PublishSubject()

    var image: String? {
        return item.image
    }

    var col: Int = 2
    var column: Int {
        return col
    }

    func makeItemType() -> DefaultColltionSectionItem {

        guard let type = item.type else { return .none }
        switch type {
        case .post:
            return .post(viewModel: self)
        case .product:
            return .product(viewModel: self)
        case .recommendPost:
            return .recommendPost(viewModel: self)
        case .recommendProduct:
            return .recommendProduct(viewModel: self)
        case .theme:
            return .theme(viewModel: self)
        case .user:
            return .user(viewModel: self)
        }
    }

    required init(item: DefaultColltionItem) {
        self.item = item

        userName.accept(item.user?.displayName)
        userHeadImageURL.accept(item.user?.userImage?.url)
        imageURL.accept(item.image?.url)
        title.accept(item.title)
        userOnline.accept(item.user?.loginStatus ?? false)
        recommended.accept(item.recommended)
        saved.accept(item.saved)
        reactionImage.accept(item.reaction?.image)
        images.accept(item.images.map { Observable.just($0.url)})
        followed.accept(item.user?.isFollow ?? false)
        displayName.accept(item.user?.displayName)
        memu.accept(item.own ? DefaultColltionMemu.own : DefaultColltionMemu.other)
        recommendButtonHidden.accept(item.own)
    }
}
