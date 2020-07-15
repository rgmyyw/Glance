//
//  ReactionsViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReactionsViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let selection: Observable<ReactionsCellViewModel>
        let footerRefresh: Observable<Void>
    }
    
    struct Output {
        let items : Driver<[ReactionsCellViewModel]>
    }
    
    private let item : BehaviorRelay<Insight>
    
    init(provider: API, item : Insight) {
        self.item = BehaviorRelay(value: item)
        super.init(provider: provider)
    }
    
    let element : BehaviorRelay<PageMapable<Reaction>> = BehaviorRelay(value: PageMapable<Reaction>())
    
    func transform(input: Input) -> Output {
        
        let elements : BehaviorRelay<[ReactionsCellViewModel]> = BehaviorRelay(value: [])
        let buttonTap = PublishSubject<ReactionsCellViewModel>()
        
        item.map { $0.recommendId}
            .flatMapLatest({ [weak self] (id) -> Observable<(RxSwift.Event<PageMapable<Reaction>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.reactions(recommendId: id, pageNum: self.page)
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
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Reaction>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                self.noMoreData.onNext(())
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.reactions(recommendId: self.item.value.recommendId, pageNum: self.page)
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
        
        buttonTap.flatMapLatest({ [weak self] (cellViewModel) -> Observable<RxSwift.Event<(ReactionsCellViewModel, Bool)>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let userId = cellViewModel.item.userId ?? ""
            let request = cellViewModel.isFollow.value ? self.provider.undoFollow(userId: userId) :
                self.provider.follow(userId: userId)
            return request.trackActivity(self.loading)
                    .trackError(self.error)
                    .map { (cellViewModel, $0)}
                    .materialize()
        }).subscribe(onNext: { (event) in
            switch event {
            case .next(let (cellViewModel, result)):
                cellViewModel.isFollow.accept(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.map { $0.list.map { item -> ReactionsCellViewModel in
            let cellViewModel =  ReactionsCellViewModel(item: item)
            cellViewModel.buttonTap.map { cellViewModel}.bind(to: buttonTap).disposed(by: self.rx.disposeBag)
            return cellViewModel
            }}.bind(to: elements).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
