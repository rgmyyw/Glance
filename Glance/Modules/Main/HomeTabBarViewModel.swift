//
//  HomeTabBarViewModel.swift
//  
//
//  Created by yanghai on 7/11/18.
//  Copyright © 2018 fwan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class HomeTabBarViewModel: ViewModel, ViewModelType {

    struct Input {
    }

    struct Output {
        let tabBarItems: Driver<[HomeTabBarItem]>
    }

    override init(provider: API) {
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {

        let tabBarItems = loggedIn.map { (loggedIn) -> [HomeTabBarItem] in
            if loggedIn {
                return [.home, .category, .cart, .mine]
            } else {
                return [.home, .category, .cart, .mine]
            }
        }.asDriver(onErrorJustReturn: [])
        
        return Output(tabBarItems: tabBarItems)
    }

    func viewModel(for tabBarItem: HomeTabBarItem) -> ViewModel {
        switch tabBarItem {
        case .home:
            let viewModel = DemoViewModel(provider: provider)
            return viewModel
        case .category:
            let viewModel = DemoViewModel(provider: provider)
            return viewModel
        case .cart:
            let viewModel = DemoViewModel(provider: provider)
            return viewModel
        case .mine:
            let viewModel = DemoViewModel(provider: provider)
            return viewModel
        }
    }
}
