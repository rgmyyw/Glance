//
//  InsightsViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


enum InsightsType  {
    case post, recommend
    
    var detailNavigationTitle : String {
        switch self {
        case .post:
            return "Post Insights"
        case .recommend:
            return "Recomm Insights"
        }
    }
    var previewButtonTitle : String {
        switch self {
        case .post:
            return "View post"
        case .recommend:
            return "View recomm"
        }
    }

}

class InsightsViewModel: ViewModel, ViewModelType {
    
    struct Input {
    }
    
    struct Output {
        
    }
    

    let selected = PublishSubject<(InsightsType,InsightsCellViewModel)>()

    
    
    
    func transform(input: Input) -> Output {
            
        
        //        input.headerRefresh
        //            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<User>)> in
        //                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
        //                return self.provider.userDetail(userId: "")
        //                    .trackError(self.error)
        //                    .trackActivity(self.headerLoading)
        //                    .materialize()
        //            }).subscribe(onNext: {  event in
        //                switch event {
        //                case .next(let item):
        //                    user.accept(item)
        //                default:
        //                    break
        //                }
        //            }).disposed(by: rx.disposeBag)
        
        let userHeadImageURL = user.map { $0?.userImage?.url}.asDriver(onErrorJustReturn: nil)
        let displayName = user.map { $0?.displayName ?? ""}.asDriver(onErrorJustReturn: "")
        let countryName = user.map { $0?.countryName ?? ""}.asDriver(onErrorJustReturn: "")
        let instagram = user.map { $0?.instagram ?? ""}.asDriver(onErrorJustReturn: "")
        let website = user.map { $0?.website ?? ""}.asDriver(onErrorJustReturn: "")
        let bio = user.map { $0?.bio ?? ""}.asDriver(onErrorJustReturn: "")
        
        let titles = user.filterNil().map { user -> [String] in
            return ["\(user.postCount)\nPost",
                "\(user.recommendCount)\nRecomm",
                "\(user.followerCount)\nFollowers",
                "\(user.followingCount)\nFollowing"]
        }.asDriver(onErrorJustReturn: ["0\nPost","0\nRecomm","0\nFollowers","0\nFollowing"])
        
        
        return Output()
    }
}


