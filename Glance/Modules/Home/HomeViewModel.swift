//
//  HomeViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<HomeSectionItem>
        
    }
    
    struct Output {
        let items : Driver<[HomeSection]>
        let showLikePopView : Observable<(UIView, HomeCellViewModel)>
        let detail : Driver<Home>
    }
    
    let element : BehaviorRelay<PageMapable<Home>> = BehaviorRelay(value: PageMapable<Home>())
    
    func transform(input: Input) -> Output {
        
        
        let elements = BehaviorRelay<[HomeSection]>(value: [])
        let saveFavorite = PublishSubject<HomeCellViewModel>()
        let showLikePopView = PublishSubject<(UIView,HomeCellViewModel)>()
        let detail = input.selection.map { $0.viewModel.item }
        
        
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.getHome(page: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
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
            return self.provider.getHome(page: self.page)
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

        
        element.map { items -> [HomeSection] in
            let sectionItems = items.list.map { item -> HomeSectionItem  in
                let viewModel = HomeCellViewModel(item: item)
                viewModel.saveFavorite.map { _ in  viewModel }.bind(to: saveFavorite).disposed(by: self.rx.disposeBag)
                viewModel.showLikePopView.map { ($0, viewModel) }.bind(to: showLikePopView).disposed(by: self.rx.disposeBag)
                let sectionItem = HomeSectionItem.recommendItem(viewModel: viewModel)
                return sectionItem
            }
            let sections = [HomeSection.recommend(items: sectionItems)]
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

        
        
            
//
//        input.selection.subscribe(onNext: { item in
//            elements.value.forEach { (i) in i.selected.accept(false) }
//            item.selected.accept(true)
//            CurrencyManager.shared.setDefault(item.item)
//            saved.onNext(())
//        }).disposed(by: rx.disposeBag)
        
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      showLikePopView: showLikePopView.asObservable(),
                      detail: detail.asDriver(onErrorJustReturn: Home()))
    }
}
