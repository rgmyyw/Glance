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
        let userDetail : Driver<User>
        let themeDetail : Driver<Int>
        let postDetail : Driver<DefaultColltionItem>
        let insightDetail : Driver<Insight>
        let notice : Driver<Void>
        let following : Driver<Void>
    }
    
    override init(provider: API) {
        super.init(provider: provider)
    }
    
    
    
    func transform(input: Input) -> Output {
        
        let postDetail = PublishSubject<DefaultColltionItem>()
        let userDetail = PublishSubject<User>()
        let themeDetail = PublishSubject<Int>()
        let insightDetail = PublishSubject<Insight>()
        let notice = PublishSubject<Void>()
        let following = PublishSubject<Void>()
        

        let tabBarItems = loggedIn.map { (loggedIn) -> [HomeTabBarItem] in            
            if loggedIn {
                return [.home, .notifications,.center, .chat, .mine]
            } else {
                return [.home, .notifications,.center ,.chat, .mine]
            }
            
        }
        
        NotificationCenter.default.rx.notification(.kNotificationReceived)
            .map { (noti) -> NotificationPayloadItem? in
            guard let userInfo = noti.userInfo as? [String : Any] ,userInfo.isNotEmpty else { return nil }
            return NotificationPayloadItem(JSON: userInfo)
        }.filterNil().subscribe(onNext: { (item) in
            guard let type = item.type else { return }
            switch type {
            case .theme:
                themeDetail.onNext(item.themeId)
            case .reacted:
                insightDetail.onNext(Insight(recommendId: item.recommendedId))
            case .liked:
                postDetail.onNext(.init(postId: item.postId))
            case .mightLike,.recommended:
                notice.onNext(())
            case .following:
                following.onNext(())
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        
        return Output(tabBarItems: tabBarItems.asDriver(onErrorJustReturn: []),
                      userDetail: userDetail.asDriverOnErrorJustComplete(),
                      themeDetail: themeDetail.asDriverOnErrorJustComplete(),
                      postDetail: postDetail.asDriverOnErrorJustComplete(),
                      insightDetail: insightDetail.asDriverOnErrorJustComplete(),
                      notice: notice.asDriverOnErrorJustComplete(),
                      following: following.asDriverOnErrorJustComplete())
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


