//
//  InsightsPostViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class InsightsChildViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<InsightsCellViewModel>
        
    }
    
    struct Output {
        let items : Driver<[InsightsCellViewModel]>
    }
        
    
    let type : BehaviorRelay<InsightsType>
    
    let selected = PublishSubject<(InsightsType,InsightsCellViewModel)>()
    
    init(provider: API, type: InsightsType) {
        self.type = BehaviorRelay(value: type)
        super.init(provider: provider)
    }
    
    let element : BehaviorRelay<PageMapable<Insight>> = BehaviorRelay(value: PageMapable<Insight>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[InsightsCellViewModel]>(value: [])

        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Insight>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                let request : Single<PageMapable<Insight>> = self.type.value == .post ?
                    self.provider.insightPost(userId: "", pageNum: self.page) :
                    self.provider.insightRecommend(userId: "", pageNum: self.page)
                return request
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    if !item.hasNext  {
                        self.noMoreData.onNext(())
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Insight>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                self.noMoreData.onNext(())
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            let request : Single<PageMapable<Insight>> = self.type.value == .post ?
                self.provider.insightPost(userId: "", pageNum: self.page) :
                self.provider.insightRecommend(userId: "", pageNum: self.page)
            return request
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = self.element.value.list + item.list
                self.element.accept(temp)
                if !item.hasNext  {
                    self.noMoreData.onNext(())
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.map { items -> [InsightsCellViewModel] in
            return items.list.map { item -> InsightsCellViewModel  in
                let viewModel = InsightsCellViewModel(item: item)
                return viewModel
            }
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        input.selection.map { (self.type.value,$0)}.bind(to: selected).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
    
}

