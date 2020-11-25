//
//  StyleBoardSearchModuleItem.swift
//  Glance
//
//  Created by yanghai on 2020/10/26.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

//enum ProductSearchType : Int {
//    case saved = 0
//    case posted
//    case inApp
//    var placeholder : String {
//        switch self {
//        case .saved:
//            return "Search saved"
//        case .posted:
//            return "Search posted"
//        case .inApp:
//            return "Search in Glance app"
//        }
//    }
//}

enum StyleBoardSearchModuleItem {

    case save(viewModel: StyleBoardSearchContentViewModel)
    case post(viewModel: StyleBoardSearchContentViewModel)
    case app(viewModel: StyleBoardSearchContentViewModel)

    var title: String {
        switch self {
        case .save:
            return "Saved"
        case .post:
            return "Your Posts"
        case .app:
            return "Search in App"
        }
    }
    var value: Int {
        switch self {
        case .save:
            return 0
        case .post:
            return 1
        case .app:
            return 2
        }
    }

    func toScene(navigator: Navigator?) -> Navigator.Scene? {
        guard navigator != nil else {
            return nil
        }
        switch self {
        case .save(let viewModel), .post(let viewModel), .app(let viewModel):
            return .styleBoardSearchContent(viewModel: viewModel)
        }
    }
}
