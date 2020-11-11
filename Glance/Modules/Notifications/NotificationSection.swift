//
//  NotificationSection.swift
//  Glance-D
//
//  Created by yanghai on 2020/11/5.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import Differentiator


enum NotificationType : Int {
    case following = 0
    case liked = 1
    case recommended = 2
    case reacted = 3
    case mightLike = 4
    case system = 5
    case theme = 6
}


enum NotificationSection : AnimatableSectionModelType,IdentifiableType {
    
    
    typealias Identity = String
    typealias Item = NotificationSectionItem
    
    var identity: String {
        return "noti"
    }
    
    var items: [NotificationSectionItem] {
        switch  self {
        case .noti(let items):
            return items.map { $0 }
        }
    }
    
    init(original: NotificationSection, items: [Item]) {
        switch original {
        case .noti(let items):
            self = .noti(items: items)
        }
    }

    
    case noti(items : [NotificationSectionItem])
}



enum NotificationSectionItem {

    case following(viewModel: NotificationCellViewModel)
    case liked(viewModel: NotificationCellViewModel)
    case recommended(viewModel: NotificationCellViewModel)
    case reacted(viewModel: NotificationCellViewModel)
    case mightLike(viewModel: NotificationCellViewModel)
    case system(viewModel: NotificationCellViewModel)
    case theme(viewModel: NotificationCellViewModel)
    

    var viewModel : NotificationCellViewModel {
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
            return NotificationFollowingCell.reuseIdentifier
        case .liked:
            return NotificationLikedCell.reuseIdentifier
        case .recommended:
            return NotificationRecommendedCell.reuseIdentifier
        case .reacted:
            return NotificationReactionCell.reuseIdentifier
        case .mightLike:
            return NotificationMightLikeCell.reuseIdentifier
        case .system:
            return NotificationSystemCell.reuseIdentifier
        case .theme:
            return NotificationThemeCell.reuseIdentifier
        }
    }
    
}

extension NotificationSectionItem: IdentifiableType {
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
extension NotificationSectionItem: Equatable {
    static func == (lhs: NotificationSectionItem, rhs: NotificationSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
