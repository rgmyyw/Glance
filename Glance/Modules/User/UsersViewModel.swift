//
//  UsersViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UsersViewModel : ViewModel, ViewModelType {
    
    struct Input {
        let selection: Observable<UsersCellViewModel>
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
    }
    
    struct Output {
        let items : Driver<[UsersCellViewModel]>
        let navigationTitle : Driver<String>
    }
    
    private let type : BehaviorRelay<UsersType>
    
    let current : BehaviorRelay<User?>
    let needUpdateTitle = PublishSubject<Bool>()

    
    init(provider: API, type : UsersType,otherUser : User? = nil) {
        self.type = BehaviorRelay(value: type)
        self.current = BehaviorRelay(value: otherUser)
        super.init(provider: provider)
        
    }
        
    let tableViewHeadHidden = BehaviorRelay(value: true)
    let element : BehaviorRelay<PageMapable<UserRelation>?> = BehaviorRelay(value: nil)
    
    func transform(input: Input) -> Output {
        
        let navigationTitle = type.map { $0.navigationTitle ?? "" }
        let elements : BehaviorRelay<[UsersCellViewModel]> = BehaviorRelay(value: [])
        let buttonTap = PublishSubject<UsersCellViewModel>()
        type.map { $0 != .blocked }.bind(to: tableViewHeadHidden).disposed(by: rx.disposeBag)

        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<UserRelation>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.users(type: self.type.value, userId: self.current.value?.userId ?? "", pageNum: self.page)
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
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<UserRelation>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !(self.element.value?.hasNext ?? false) {
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.users(type: self.type.value, userId: self.current.value?.userId ?? "", pageNum: self.page)
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
        
        
        buttonTap.map { (cellViewModel) -> (UsersCellViewModel, Single<Bool>) in
            let userId = cellViewModel.item.model.userId ?? ""
            switch self.type.value {
            case .following,.followers:
                return (cellViewModel,cellViewModel.buttonSelected.value ? self.provider.undoFollow(userId: userId) : self.provider.follow(userId: userId))
            case .blocked:
                return (cellViewModel,cellViewModel.buttonSelected.value ? self.provider.undoBlocked(userId: userId) : self.provider.block(userId: userId))
            }
        }.flatMapLatest({ [weak self] (cellViewModel, request ) -> Observable<RxSwift.Event<(UsersCellViewModel, Bool)>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return request.trackActivity(self.loading)
                .trackError(self.error)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            switch event {
            case .next(let (cellViewModel, result)):
                cellViewModel.buttonSelected.accept(result)
                self?.needUpdateTitle.onNext(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.filterNil().map { $0.list.map { item -> UsersCellViewModel in
            let cellViewModel =  UsersCellViewModel(item: (self.type.value,item))
            cellViewModel.buttonTap.map { cellViewModel}.bind(to: buttonTap).disposed(by: self.rx.disposeBag)
            self.type.map { $0.cellButtonNormalTitle }.bind(to: cellViewModel.buttonNormalTitle).disposed(by: self.rx.disposeBag)
            self.type.map { $0.cellButtonSelectedTitle }.bind(to: cellViewModel.buttonSelectedTitle).disposed(by: self.rx.disposeBag)
            
            return cellViewModel
            }}.bind(to: elements).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      navigationTitle: navigationTitle.asDriverOnErrorJustComplete())
    }
}

