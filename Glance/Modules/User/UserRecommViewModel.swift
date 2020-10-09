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
        let selection : Observable<DefaultColltionSectionItem>
        
    }
    
    struct Output {
        let items : Driver<[UserRecommSection]>
        let detail : Driver<Home>
    }
    
    let element : BehaviorRelay<PageMapable<Home>?> = BehaviorRelay(value: nil)
    let needUpdateTitle = PublishSubject<Bool>()
    let current = BehaviorRelay<User?>(value: nil)
    
    init(provider: API, otherUser : User? = nil) {
        super.init(provider: provider)
        current.accept(otherUser)
    }

    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[UserRecommSection]>(value: [])
        let save = PublishSubject<DefaultColltionCellViewModel>()
        let reaction = PublishSubject<(UIView,DefaultColltionCellViewModel)>()
        let detail = input.selection.map { $0.viewModel.item }
        let recommend = PublishSubject<DefaultColltionCellViewModel>()
        let more = PublishSubject<DefaultColltionCellViewModel>()
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.userRecommend(userId: self.current.value?.userId ?? "",pageNum: self.page)
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
            if !(self.element.value?.hasNext ?? false) {
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.userRecommend(userId: self.current.value?.userId ?? "",pageNum: self.page)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = (self.element.value?.list ?? []) + item.list
                self.element.accept(temp)
                self.hasData.onNext(item.hasNext)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.filterNil().map { items -> [UserRecommSection] in
            let sectionItems = items.list.map { item -> DefaultColltionSectionItem  in
                let viewModel = DefaultColltionCellViewModel(item: item)
                viewModel.save.map { _ in  viewModel }.bind(to: save).disposed(by: self.rx.disposeBag)
                viewModel.reaction.map { ($0, viewModel) }.bind(to: reaction).disposed(by: self.rx.disposeBag)
                viewModel.recommend.map { viewModel }.bind(to: recommend).disposed(by: self.rx.disposeBag)
                viewModel.more.map { viewModel }.bind(to: more).disposed(by: self.rx.disposeBag)
                viewModel.recommendButtonHidden.accept(((self.current.value != nil) ? self.current.value != user.value : false))
                return viewModel.makeItemType()
            }
            
            let sections = [UserRecommSection.single(items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)

        
        
        save.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(DefaultColltionCellViewModel,Bool)>)> in
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
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let (cellViewModel,result)):
                cellViewModel.saved.accept(result)
                var item = cellViewModel.item
                item.recommended = result
                kUpdateItem.onNext((.saved,item,self))
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        recommend.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(DefaultColltionCellViewModel,Bool)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            var params = [String : Any]()
            params["recommend"] = !cellViewModel.recommended.value
            params.merge(dict: cellViewModel.item.id)
            return self.provider.recommend(param: params)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: {  [weak self]event in
            switch event {
            case .next(let (cellViewModel,result)):
                cellViewModel.recommended.accept(result)
                var item = cellViewModel.item
                item.recommended = result
                kUpdateItem.onNext((.recommend,item,self))
                self?.needUpdateTitle.onNext(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        more.subscribe(onNext: { (cellViewModel) in
            cellViewModel.memuHidden.accept(!cellViewModel.memuHidden.value)
        }).disposed(by: rx.disposeBag)

        
        kUpdateItem.subscribe(onNext: { [weak self](state, item,trigger) in
            guard trigger != self else { return }
            guard var t = self?.element.value else { return }
            let items =  elements.value.first?.items
            switch state {
            case .delete:
                var list = t.list
                if let index = list.firstIndex(where: { $0 == item}) {
                    list.remove(at: index)
                    t.list = list
                    self?.element.accept(t)
                }
            case .like:
                break
            case .saved:
                items?.forEach { $0.viewModel.saved.accept(item.saved)}
            case .recommend:
                var element = self?.element.value
                if item.recommended == false {
                    element?.list.removeAll(where: { $0 == item})
                } else {
                    element?.list.insert(item, at: 0)
                }
                element?.list.removeDuplicates()
                self?.element.accept(element)
            }
                
        }).disposed(by: rx.disposeBag)

        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      detail: detail.asDriverOnErrorJustComplete())
    }
}
