//
//  NoticeSection.swift
//  Glance-D
//
//  Created by yanghai on 2020/11/5.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import Differentiator


enum NoticeType : Int {
    case following = 1
    case liked = 2
    case recommended = 3
    case reacted = 4
    case mightLike = 20
    case system = 0
    case theme = 21
}


enum NoticeSection : AnimatableSectionModelType,IdentifiableType {
    
    
    typealias Identity = String
    typealias Item = NoticeSectionItem
    
    case noti(items : [NoticeSectionItem])
    
    var identity: String {
        return "noti"
    }
    
    var items: [NoticeSectionItem] {
        switch  self {
        case .noti(let items):
            return items.map { $0 }
        }
    }
    
    init(original: NoticeSection, items: [Item]) {
        switch original {
        case .noti:
            self = .noti(items: items)
        }
    }

}



enum NoticeSectionItem {

    case following(viewModel: NoticeCellViewModel)
    case liked(viewModel: NoticeCellViewModel)
    case recommended(viewModel: NoticeCellViewModel)
    case reacted(viewModel: NoticeCellViewModel)
    case mightLike(viewModel: NoticeCellViewModel)
    case system(viewModel: NoticeCellViewModel)
    case theme(viewModel: NoticeCellViewModel)
    

    var viewModel : NoticeCellViewModel {
        switch self {
        case .following(let viewModel):
            return viewModel
        case .liked(let viewModel):
            return viewModel
        case .recommended(let viewModel):
            return viewModel
        case .reacted(let viewModel):
            return viewModel
        case .mightLike(let viewModel):
            return viewModel
        case .system(let viewModel):
            return viewModel
        case .theme(let viewModel):
            return viewModel
        }
    }
    
    var reuseIdentifier: String {
        switch self {
        case .following:
            return NoticeFollowingCell.reuseIdentifier
        case .liked:
            return NoticeLikedCell.reuseIdentifier
        case .recommended:
            return NoticeRecommendedCell.reuseIdentifier
        case .reacted:
            return NoticeReactionCell.reuseIdentifier
        case .mightLike:
            return NoticeMightLikeCell.reuseIdentifier
        case .system:
            return NoticeSystemCell.reuseIdentifier
        case .theme:
            return NoticeThemeCell.reuseIdentifier
        }
    }
    
}

extension NoticeSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        switch self {
        default:
            return "noticeId:\(viewModel.item.noticeId.string)"
        }
    }
}
extension NoticeSectionItem: Equatable {
    static func == (lhs: NoticeSectionItem, rhs: NoticeSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
