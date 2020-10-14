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


enum UpdateItemState {
    case saved
    case like
    case recommend
    case delete
}

enum UpdateUserDataType {
    case post
    case recommend
    case followers
    case following
}




let kUpdateItem = PublishSubject<(state : UpdateItemState, item : Home, trigger : ViewModel? )>()
let kUpdateUserData = PublishSubject<(type : UpdateUserDataType, item : Home, trigger : ViewModel? )>()



class HomeViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<DefaultColltionSectionItem>
        let search : Observable<Void>
        
    }
    
    struct Output {
        let items : Driver<[HomeSection]>
        let reaction : Observable<(UIView, DefaultColltionCellViewModel)>
        let detail : Driver<Home>
        let userDetail : Driver<User>
        let search : Observable<Void>
    }
    
    let element : BehaviorRelay<PageMapable<Home>?> = BehaviorRelay(value: nil)
    
    
    let selectionReaction = PublishSubject<(cellViewModel : DefaultColltionCellViewModel , type : ReactionType)>()
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[HomeSection]>(value: [])
        let save = PublishSubject<DefaultColltionCellViewModel>()
        let reaction = PublishSubject<(UIView,DefaultColltionCellViewModel)>()
        let detail = input.selection.map { $0.viewModel.item }
        let recommend = PublishSubject<DefaultColltionCellViewModel>()
        let userDetail = PublishSubject<User?>()
        let more = PublishSubject<DefaultColltionCellViewModel>()
        let like = PublishSubject<DefaultColltionCellViewModel>()
        
        //let share = PublishSubject<DefaultColltionCellViewModel>()
        //let delete = PublishSubject<DefaultColltionCellViewModel>()
        //let report = PublishSubject<DefaultColltionCellViewModel>()
        
        more.subscribe(onNext: { (cellViewModel) in
            cellViewModel.memuHidden.accept(!cellViewModel.memuHidden.value)
        }).disposed(by: rx.disposeBag)
        
        
        like.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(DefaultColltionCellViewModel,Bool)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                var params = [String : Any]()
                params["type"] = cellViewModel.item.type?.isProduct.int ?? 0
                params["updateLiked"] = !cellViewModel.liked.value
                params.merge(dict: cellViewModel.item.id)
                return self.provider.like(param: params)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .map { (cellViewModel, $0)}
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let (cellViewModel, result)):
                    cellViewModel.liked.accept(result)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(.error(ExceptionError.unknown))
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
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error  {
                    default:
                        self.endLoading.onNext(())
                        logError(error.debugDescription)
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh
            .flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Home>>> in
                guard let self = self,
                    self.element.value?.list.isNotEmpty ?? false else {
                    return Observable.just(.error(ExceptionError.empty))
                }
                guard (self.element.value?.hasNext ?? false) else {
                    return Observable.just(.error(ExceptionError.noMore))
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
                    temp.list = (self.element.value?.list ?? []) + item.list
                    self.element.accept(temp)
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error  {
                    case .noMore:
                        self.noMoreData.onNext(())
                    default:
                        self.endLoading.onNext(())
                        logError(error.debugDescription)
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        element.filterNil().map { items -> [HomeSection] in
            let sectionItems = items.list.map { item -> DefaultColltionSectionItem  in
                let viewModel = DefaultColltionCellViewModel(item: item)
                viewModel.save.map { _ in  viewModel }.bind(to: save).disposed(by: self.rx.disposeBag)
                viewModel.reaction.map { ($0, viewModel) }.bind(to: reaction).disposed(by: self.rx.disposeBag)
                viewModel.recommend.map { viewModel }.bind(to: recommend).disposed(by: self.rx.disposeBag)
                viewModel.userDetail.map { viewModel.item.user }.bind(to: userDetail).disposed(by: self.rx.disposeBag)
                viewModel.more.map { viewModel }.bind(to: more).disposed(by: self.rx.disposeBag)
                return viewModel.makeItemType()
            }
            let sections = [HomeSection.single(items: sectionItems)]
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
                      userDetail: userDetail.filterNil().asDriver(onErrorJustReturn: User()),
                      search: input.search)
    }
}
