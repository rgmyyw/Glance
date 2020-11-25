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

class NoticeCellViewModel: CellViewModelProtocol {

    let item: Notice
    let userImageURL: BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let userName: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let userState: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    let description: BehaviorRelay<NSAttributedString?> = BehaviorRelay(value: nil)
    let time: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let image: BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let reaction: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    let read: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    let following: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let theme: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let themeImages: BehaviorRelay<[Observable<URL?>]> = BehaviorRelay(value: [])

    let follow: PublishSubject<Void> = PublishSubject()
    let delete: PublishSubject<Void> = PublishSubject()
    let userDetail: PublishSubject<Void> = PublishSubject()
    let themeDetail: PublishSubject<Void> = PublishSubject()
    let postDetail: PublishSubject<Void> = PublishSubject()

    required init(item: Notice) {
        self.item = item

        self.userImageURL.accept(item.user?.userImage?.url)
        self.userName.accept(item.user?.username)
        self.following.accept(item.user?.isFollow ?? false)
        self.time.accept(item.noticeTime?.customizedString())
        self.image.accept(item.image?.url)
        self.read.accept(item.read)
        self.reaction.accept(item.user?.reaction?.image)
        self.theme.accept(item.title)

        let replace = "******"
        if let title = item.title, title.contains(replace) {
            let first = title.nsString.range(of: replace)
            let last = title.nsString.range(of: replace, options: .backwards)
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(hex: 0x666666)!, .font: UIFont.titleFont(12)]
            let str = NSMutableAttributedString(string: title, attributes: attributes)
            let range = NSRange(location: first.location, length: (last.location + last.length) - first.location)
            str.addAttributes([.foregroundColor: UIColor(hex: 0x5480B1)!], range: range)
            str.replaceCharacters(in: first, with: "")
            str.replaceCharacters(in: str.string.nsString.range(of: replace, options: .backwards), with: "")
            description.accept(str)
        }

        self.themeImages.accept(item.images.map { Observable.just($0.url)})
    }

    func makeItemType() -> NoticeSectionItem {

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
