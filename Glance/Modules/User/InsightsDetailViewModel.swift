//
//  InsightsDetailViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class InsightsDetailViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let selection : Observable<Int>
    }
    
    struct Output {
        
        let imageURL : Driver<URL?>
        let title : Driver<String>
        let time : Driver<String>
        let reachedCount : Driver<String>
        let interactionsCount : Driver<String>
        let saveCount : Driver<String>
        let recommendsCount : Driver<String>
        let likesCount : Driver<String>
        let sharesCount : Driver<String>
        let reactionsCount : Driver<String>
        let available : Observable<[Int]>
        let previewButtonTitle : Driver<String>
        let navigationTitle :  Driver<String>
        let reaction : Observable<Insight>
    }
    
    private let item : BehaviorRelay<Insight>
    private let type : BehaviorRelay<InsightsType>
    
    
    init(provider: API, type : InsightsType, item : Insight) {
        self.item = BehaviorRelay(value: item)
        self.type = BehaviorRelay(value: type)
        super.init(provider: provider)
    }
    
    
    
    func transform(input: Input) -> Output {

        let element = BehaviorRelay<InsightsDetail?>(value: nil)
        let available = type.map { $0 == .post ? [0,2,3,4] : [1,2]}
        let previewButtonTitle = type.map { $0.previewButtonTitle }.asDriver(onErrorJustReturn: "")
        let navigationTitle = type.map { $0.detailNavigationTitle }.asDriver(onErrorJustReturn: "")

        let reaction = input.selection.filter { $0 == 1}.map { _ in self.item.value }
        
        
        Observable.zip(type,item).flatMapLatest({ [weak self] (type, item) -> Observable<(RxSwift.Event<InsightsDetail>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let request : Single<InsightsDetail> = type == .post ?
                self.provider.insightsPostDetail(postId: item.postId):
                self.provider.insightsrRecommendDetail(recommendId: item.recommendId)
            return request
                .trackActivity(self.loading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { event in
            switch event {
            case .next(let result):
                element.accept(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        
        
        let imageURL = element.filterNil().map { $0.image?.url }.asDriver(onErrorJustReturn: nil)
        let title = element.filterNil().map { $0.title  ?? "" }.asDriver(onErrorJustReturn: "")
        let time = element.filterNil().map { $0.created?.dateString(ofStyle: .medium) ?? "" }.asDriver(onErrorJustReturn: "")
        let reachedCount = element.filterNil().map { $0.reachCount.string }.asDriver(onErrorJustReturn: "")
        let interactionsCount = element.filterNil().map { $0.interactionsCount.string }.asDriver(onErrorJustReturn: "")
        let saveCount = element.filterNil().map { $0.saveCount.string }.asDriver(onErrorJustReturn: "")
        let recommendsCount = element.filterNil().map { $0.recommendsCount.string }.asDriver(onErrorJustReturn: "")
        let likesCount = element.filterNil().map { $0.likesCount.string }.asDriver(onErrorJustReturn: "")
        let sharesCount = element.filterNil().map { $0.sharesCount.string }.asDriver(onErrorJustReturn: "")
        let reactionsCount = element.filterNil().map { $0.reactionsCount.string }.asDriver(onErrorJustReturn: "")

            
        
//        commit.flatMapLatest({ [weak self] (data) -> Observable<(RxSwift.Event<User>)> in
//            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
//            return self.provider.modifyProfile(data: data)
//                .trackActivity(self.loading)
//                .trackError(self.error)
//                .materialize()
//        }).subscribe(onNext: { [weak self] event in
//            switch event {
//            case .next(let item):
//                user.accept(item)
//            default:
//                break
//            }
//        }).disposed(by: rx.disposeBag)
        
        
        
        return Output(imageURL: imageURL, title: title, time: time, reachedCount: reachedCount, interactionsCount: interactionsCount, saveCount: saveCount, recommendsCount: recommendsCount, likesCount: likesCount, sharesCount: sharesCount, reactionsCount: reactionsCount, available: available, previewButtonTitle: previewButtonTitle,navigationTitle : navigationTitle, reaction: reaction)
        
    }
}

