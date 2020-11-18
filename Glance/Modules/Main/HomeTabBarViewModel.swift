//
//  HomeTabBarViewModel.swift
//  
//
//  Created by yanghai on 7/11/18.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import AppAuth

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
                return [.home, .notifications,.center, .chat, .mine]
            } else {
                return [.home, .notifications,.center ,.chat, .mine]
            }
            
        }.asDriver(onErrorJustReturn: [])
        
        return Output(tabBarItems: tabBarItems)
    }
    
    func viewModel(for tabBarItem: HomeTabBarItem) -> ViewModel {
        switch tabBarItem {
        case .home:
            let viewModel = HomeViewModel(provider: provider)
            return viewModel
        case .notifications:
            let viewModel = NoticeViewModel(provider: provider)
            return viewModel
        case .chat:
            let viewModel = NoticeViewModel(provider: provider)
            return viewModel
        case .mine:
            let viewModel = UserDetailViewModel(provider: provider)
            return viewModel
        case .center:
            let viewModel = DemoViewModel(provider: provider)
            return viewModel
        }
    }
}


