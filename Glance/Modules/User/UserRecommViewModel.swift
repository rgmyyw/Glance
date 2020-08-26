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
        let detail : Driver<Home>
    }
    
    let element : BehaviorRelay<PageMapable<Home>> = BehaviorRelay(value: PageMapable<Home>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,UserRecommCellViewModel>]>(value: [])
        let save = PublishSubject<UserRecommCellViewModel>()
        let showLikePopView = PublishSubject<(UIView,UserRecommCellViewModel)>()
        let detail = input.selection.map { $0.item }.asDriver(onErrorJustReturn: Home())
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
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
                self.hasData.onNext(item.hasNext)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.map { items -> [SectionModel<Void,UserRecommCellViewModel>] in
            let sectionItems = items.list.map { item -> UserRecommCellViewModel  in
                let viewModel = UserRecommCellViewModel(item: item)
                viewModel.save.map { _ in  viewModel }.bind(to: save).disposed(by: self.rx.disposeBag)
                viewModel.showLikePopView.map { ($0, viewModel) }.bind(to: showLikePopView).disposed(by: self.rx.disposeBag)
                return viewModel
            }
            let sections = [SectionModel<Void,UserRecommCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        save.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(UserRecommCellViewModel,Bool)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            var params = [String : Any]()
            params["type"] = cellViewModel.item.type?.rawValue ?? -1
            params["updateSaved"] = !cellViewModel.saved.value
            params.merge(dict: cellViewModel.item.id)
            return self.provider.saveCollection(param: params)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: { event in
            switch event {
            case .next(let (cellViewModel, result)):
                cellViewModel.saved.accept(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      showLikePopView: showLikePopView.asObservable(),
                      detail: detail)
    }
}
