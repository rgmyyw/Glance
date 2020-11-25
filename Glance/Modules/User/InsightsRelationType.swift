//
//  InsightsRelationType.swift
//  Glance
//
//  Created by yanghai on 2020/11/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import Foundation

enum InsightsRelationType {
    case liked, recommend

    var navigationTitle: String {
        switch self {
        case .liked:
            return "Likes By"
        case .recommend:
            return "Recommends By"
        }
    }
}
