//
//  UserRecommViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class UserRecommViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<UserRecommCellViewModel>
        
    }
    
    struct Output {
        let items : Driver<[SectionModel<Void,UserRecommCellViewModel>]>
        let showLikePopView : Observable<(UIView, UserRecommCellViewModel)>
    }
    
    let element : BehaviorRelay<PageMapable<Recommend>> = BehaviorRelay(value: PageMapable<Recommend>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,UserRecommCellViewModel>]>(value: [])
        let saveFavorite = PublishSubject<UserRecommCellViewModel>()
        let showLikePopView = PublishSubject<(UIView,UserRecommCellViewModel)>()
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Recommend>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.userRecommend(userId: "",pageNum: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
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
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Recommend>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                self.noMoreData.onNext(())
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.userRecommend(userId: "",pageNum: self.page)
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

        
        element.map { items -> [SectionModel<Void,UserRecommCellViewModel>] in
            let sectionItems = items.list.map { item -> UserRecommCellViewModel  in
                let viewModel = UserRecommCellViewModel(item: item)
                viewModel.saveFavorite.map { _ in  viewModel }.bind(to: saveFavorite).disposed(by: self.rx.disposeBag)
                viewModel.showLikePopView.map { ($0, viewModel) }.bind(to: showLikePopView).disposed(by: self.rx.disposeBag)
                return viewModel
            }
            let sections = [SectionModel<Void,UserRecommCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
//        saveFavorite
//            .flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(HomeCellViewModel,Bool)>)> in
//                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
//                guard let type = cellViewModel.item.type else { return Observable.just(RxSwift.Event.completed) }
//                let id : Any
//                switch type {
//                case .post:
//                    id = cellViewModel.item.posts?.postId ?? 0
//                case .product:
//                    id = cellViewModel.item.product?.imName ?? ""
//                case .recommend:
//                    id = cellViewModel.item.recommend?.recommendId ?? 0
//                }
//                return self.provider.saveFavorite(id: id, type: type.rawValue)
//                    .trackError(self.error)
//                    .trackActivity(self.loading)
//                    .map { (cellViewModel, $0)}
//                    .materialize()
//            }).subscribe(onNext: { [weak self] event in
//                guard let self = self else { return }
//                switch event {
//                case .next(let (item,result)):
//                    if result {
//                        item.isFavorite.accept(result)
//                    }
//                default:
//                    break
//                }
//            }).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []), showLikePopView: showLikePopView.asObservable())
    }
}
