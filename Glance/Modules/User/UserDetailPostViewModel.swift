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

class UserDetailPostViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<DefaultColltionSectionItem>
        
    }
    
    struct Output {
        let items : Driver<[UserDetailPostSection]>
        let detail : Driver<DefaultColltionItem>
    }
    
    let otherUser : BehaviorRelay<User?>

    init(provider: API,otherUser : User?) {
        self.otherUser = BehaviorRelay(value : otherUser)
        super.init(provider: provider)
    }
    
    
    let element : BehaviorRelay<PageMapable<DefaultColltionItem>?> = BehaviorRelay(value: nil)
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[UserDetailPostSection]>(value: [])
        
        let save = PublishSubject<DefaultColltionCellViewModel>()
        let reaction = PublishSubject<(UIView,DefaultColltionCellViewModel)>()
        let detail = input.selection.map { $0.viewModel.item }
        let recommend = PublishSubject<DefaultColltionCellViewModel>()
        let more = PublishSubject<DefaultColltionCellViewModel>()
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<DefaultColltionItem>>)> in
                guard let self = self else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                self.page = 1
                return self.provider.userPost(userId: self.otherUser.value?.userId ?? "",pageNum: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    self.refreshState.onNext(item.refreshState)
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error  {
                    default:
                        self.refreshState.onNext(.end)
                        logError(error.debugDescription)
                    }

                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<DefaultColltionItem>>> in
            guard let self = self else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            self.page += 1
            return self.provider.userPost(userId: self.otherUser.value?.userId ?? "",pageNum: self.page)
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
                self.refreshState.onNext(item.refreshState)
            case .error(let error):
                guard let error = error.asExceptionError else { return }
                switch error  {
                default:
                    self.page -= 1
                    self.refreshState.onNext(.end)
                    logError(error.debugDescription)
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        element.filterNil().map { items -> [UserDetailPostSection] in
            let sectionItems = items.list.map { item -> DefaultColltionSectionItem  in
                let viewModel = DefaultColltionCellViewModel(item: item)
                viewModel.save.map { _ in  viewModel }.bind(to: save).disposed(by: self.rx.disposeBag)
                viewModel.reaction.map { ($0, viewModel) }.bind(to: reaction).disposed(by: self.rx.disposeBag)
                viewModel.recommend.map { viewModel }.bind(to: recommend).disposed(by: self.rx.disposeBag)
                viewModel.more.map { viewModel }.bind(to: more).disposed(by: self.rx.disposeBag)
                viewModel.recommendButtonHidden.accept(((self.otherUser.value != nil) ? self.otherUser.value != user.value : false))
                return viewModel.makeItemType()
            }
            let sections = [UserDetailPostSection.single(items: sectionItems)]
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
            case .next(let (cellViewModel, result)):
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

        more.subscribe(onNext: { (cellViewModel) in
            cellViewModel.memuHidden.accept(!cellViewModel.memuHidden.value)
        }).disposed(by: rx.disposeBag)

        kUpdateItem.subscribe(onNext: { [weak self](state, item,trigger) in
            guard trigger != self , self?.otherUser.value == nil else { return }
            guard var t = self?.element.value else { return }
            let items = elements.value.flatMap { $0.items }.filter { $0.viewModel.item == item}
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
                items.forEach { $0.viewModel.saved.accept(item.saved)}
            case .recommend:
                items.forEach { $0.viewModel.recommended.accept(item.recommended)}
            }
        }).disposed(by: rx.disposeBag)
    
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      detail: detail.asDriverOnErrorJustComplete())
        
    }
}
