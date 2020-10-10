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
        let selection : Observable<UserPostCellViewModel>
        
    }
    
    struct Output {
        let items : Driver<[SectionModel<Void,UserPostCellViewModel>]>
        let detail : Driver<Home>
    }
    
    let otherUser : BehaviorRelay<User?>

    init(provider: API,otherUser : User?) {
        self.otherUser = BehaviorRelay(value : otherUser)
        super.init(provider: provider)
    }
    
    
    let element : BehaviorRelay<PageMapable<Home>> = BehaviorRelay(value: PageMapable<Home>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,UserPostCellViewModel>]>(value: [])
        let save = PublishSubject<UserPostCellViewModel>()
        let detail = input.selection.map { $0.item }.asDriver(onErrorJustReturn: Home())
        let recommend = PublishSubject<UserPostCellViewModel>()

        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
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
            return self.provider.userPost(userId: self.otherUser.value?.userId ?? "",pageNum: self.page)
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
                viewModel.recommendButtonHidden.accept((self.otherUser.value != nil) ? self.otherUser.value == user.value : true)
                viewModel.recommend.map { viewModel}.bind(to: recommend).disposed(by: self.rx.disposeBag)
                viewModel.save.map { _ in  viewModel }.bind(to: save).disposed(by: self.rx.disposeBag)
                return viewModel
            }
            let sections = [SectionModel<Void,UserPostCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        save.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(UserPostCellViewModel,Bool)>)> in
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
        

        recommend.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(UserPostCellViewModel,Bool)>)> in
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

        
        kUpdateItem.subscribe(onNext: { [weak self](state, item,trigger) in
            guard trigger != self , self?.otherUser.value == nil else { return }
            guard var t = self?.element.value else { return }
            let items = elements.value.flatMap { $0.items }.filter { $0.item == item}
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
                      detail: detail)
        
    }
}
