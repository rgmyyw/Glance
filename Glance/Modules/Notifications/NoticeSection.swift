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
    case following = 0
    case liked = 1
    case recommended = 2
    case reacted = 3
    case mightLike = 4
    case system = 5
    case theme = 6
}


enum NoticeSection : AnimatableSectionModelType,IdentifiableType {
    
    
    typealias Identity = String
    typealias Item = NoticeSectionItem
    
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
        case .noti(let items):
            self = .noti(items: items)
        }
    }

    
    case noti(items : [NoticeSectionItem])
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
        case .following(let viewModel):
            return viewModel.item.notificationId.string
        default:
            return ""
        }
    }
}
extension NoticeSectionItem: Equatable {
    static func == (lhs: NoticeSectionItem, rhs: NoticeSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
