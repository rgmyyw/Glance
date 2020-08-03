//
//  UserPostViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class UserPostViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<UserPostCellViewModel>
        
    }
    
    struct Output {
        let items : Driver<[SectionModel<Void,UserPostCellViewModel>]>
        let showLikePopView : Observable<(UIView, UserPostCellViewModel)>
        let detail : Driver<Home>
    }
    
    let element : BehaviorRelay<PageMapable<Home>> = BehaviorRelay(value: PageMapable<Home>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,UserPostCellViewModel>]>(value: [])
        let saveFavorite = PublishSubject<UserPostCellViewModel>()
        let showLikePopView = PublishSubject<(UIView,UserPostCellViewModel)>()
        let detail = input.selection.map { $0.item }.asDriver(onErrorJustReturn: Home())
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.userPost(userId: "",pageNum: self.page)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    
                self.hasData.onNext(item.hasNext)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Home>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.userPost(userId: "",pageNum: self.page)
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
                self.hasData.onNext(item.hasNext)
                
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        element.map { items -> [SectionModel<Void,UserPostCellViewModel>] in
            let sectionItems = items.list.map { item -> UserPostCellViewModel  in
                let viewModel = UserPostCellViewModel(item: item)
                viewModel.saveFavorite.map { _ in  viewModel }.bind(to: saveFavorite).disposed(by: self.rx.disposeBag)
                viewModel.showLikePopView.map { ($0, viewModel) }.bind(to: showLikePopView).disposed(by: self.rx.disposeBag)
                return viewModel
            }
            let sections = [SectionModel<Void,UserPostCellViewModel>(model: (), items: sectionItems)]
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
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      showLikePopView: showLikePopView.asObservable(),
                      detail: detail)
        
    }
}
