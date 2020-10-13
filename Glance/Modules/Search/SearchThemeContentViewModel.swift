//
//  SearchResultContentViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchThemeContentViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<DefaultColltionSectionItem>
    }
    
    struct Output {
        let items : Driver<[SearchResultContentViewSection]>
        let reaction : Observable<(UIView, DefaultColltionCellViewModel)>
        let detail : Driver<Home>
        let userDetail : Driver<User>
    }
    
    let element : BehaviorRelay<PageMapable<Home>?> = BehaviorRelay(value: nil)
    let selectionReaction = PublishSubject<(cellViewModel : DefaultColltionCellViewModel , type : ReactionType)>()
    let type : BehaviorRelay<SearchThemeContentType>
    let themeId : BehaviorRelay<Int>
    
    
    init(provider: API, type : SearchThemeContentType, themeId : Int) {
        self.type = BehaviorRelay(value: type)
        self.themeId = BehaviorRelay(value: themeId)
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {
        
        
        let elements = BehaviorRelay<[SearchResultContentViewSection]>(value: [])
        let save = PublishSubject<DefaultColltionCellViewModel>()
        let reaction = PublishSubject<(UIView,DefaultColltionCellViewModel)>()
        let detail = input.selection.filter { _ in self.type.value != .user }.map { $0.viewModel.item }
        let recommend = PublishSubject<DefaultColltionCellViewModel>()
        let userDetail = PublishSubject<User?>()
        let follow = PublishSubject<DefaultColltionCellViewModel>()
        input.selection.filter { _ in self.type.value == .user }
            .map { $0.viewModel.item.user }.bind(to: userDetail).disposed(by: rx.disposeBag)
        
        
        themeId.asObservable().merge(with: input.headerRefresh.map { self.themeId.value})
            .flatMapLatest({ [weak self] (themeId) -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                let type = self.type.value
                self.page = 1
                return self.provider.searchThemeDetaiResource(type: type, themeId: themeId, page: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    self.noMoreData.onNext(())
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh
            .flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Home>>> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                if !(self.element.value?.hasNext ?? false) {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page += 1
                let themeId = self.themeId.value
                let type = self.type.value
                return self.provider.searchThemeDetaiResource(type: type, themeId: themeId, page: self.page)
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
                    self.noMoreData.onNext(())
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        element.filterNil().map { items -> [SearchResultContentViewSection] in
            let section : SearchResultContentViewSection
            let sectionItems = items.list.map { item -> DefaultColltionSectionItem  in
                let viewModel = DefaultColltionCellViewModel(item: item)
                viewModel.save.map { _ in  viewModel }.bind(to: save).disposed(by: self.rx.disposeBag)
                viewModel.reaction.map { ($0, viewModel) }.bind(to: reaction).disposed(by: self.rx.disposeBag)
                viewModel.recommend.map { viewModel }.bind(to: recommend).disposed(by: self.rx.disposeBag)
                viewModel.userDetail.map { viewModel.item.user }.bind(to: userDetail).disposed(by: self.rx.disposeBag)
                viewModel.follow.map { viewModel }.bind(to: follow).disposed(by: self.rx.disposeBag)
                return viewModel.makeItemType()
            }
            if self.type.value == .user {
                section = SearchResultContentViewSection.users(items: sectionItems)
            } else {
                section = SearchResultContentViewSection.single(items: sectionItems)
            }
            return [section]
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
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        follow.flatMapLatest({ [weak self] (cellViewModel) -> Observable<RxSwift.Event<(Bool, DefaultColltionCellViewModel)>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let isFollow = cellViewModel.followed.value
            let userId = cellViewModel.item.user?.userId ?? ""
            let request = isFollow ? self.provider.undoFollow(userId: userId)
                : self.provider.follow(userId: userId)
            return request
                .trackActivity(self.loading)
                .trackError(self.error)
                .map { ($0,cellViewModel)}
                .materialize()
        }).subscribe(onNext: { (event) in
            switch event {
            case .next(let (result, cellViewModel)):
                cellViewModel.followed.accept(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        selectionReaction.flatMapLatest({ [weak self] (cellViewModel,type) -> Observable<(RxSwift.Event<(DefaultColltionCellViewModel,ReactionType,Bool)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let recommendId = cellViewModel.item.recommendId
            return self.provider.reaction(recommendId: recommendId, type: type.rawValue)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { (cellViewModel,type,$0)}
                .materialize()
        }).subscribe(onNext: {  event in
            switch event {
            case .next(let (cellViewModel, type, result)):
                if result {
                    cellViewModel.reactionImage.accept(type.image)
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        
        
        
        kUpdateItem.subscribe(onNext: { [weak self](state, item ,trigger) in
            guard trigger != self else { return }
            guard var t = self?.element.value else { return }
            let items = elements.value.flatMap { $0.items.compactMap { $0.viewModel }}.filter { $0.item == item}
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
                items.forEach { $0.saved.accept(item.saved)}
            case .recommend:
                items.forEach { $0.recommended.accept(item.recommended)}
            }
            
        }).disposed(by: rx.disposeBag)
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      reaction: reaction.asObservable(),
                      detail: detail.asDriver(onErrorJustReturn: Home()),
                      userDetail: userDetail.filterNil().asDriver(onErrorJustReturn: User()))
    }
}
