//
//  BlockedListViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserRelationViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let selection: Observable<UserRelationCellViewModel>
        let footerRefresh: Observable<Void>
    }
    
    struct Output {
        let items : Driver<[UserRelationCellViewModel]>
        let navigationTitle : Driver<String>
    }
    
    private let type : BehaviorRelay<UserRelationType>
    
    init(provider: API, type : UserRelationType) {
        self.type = BehaviorRelay(value: type)
        super.init(provider: provider)
    }
    
    let tableViewHeadHidden = BehaviorRelay(value: true)
    let element : BehaviorRelay<PageMapable<UserRelation>> = BehaviorRelay(value: PageMapable<UserRelation>())
    
    func transform(input: Input) -> Output {
        
        type.map { $0 != .blocked }.bind(to: tableViewHeadHidden).disposed(by: rx.disposeBag)
        let navigationTitle = type.map { $0.navigationTitle }.asDriver(onErrorJustReturn: "")
        let elements : BehaviorRelay<[UserRelationCellViewModel]> = BehaviorRelay(value: [])
        let buttonTap = PublishSubject<UserRelationCellViewModel>()
        
        Observable.just(())
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<UserRelation>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.userRelation(type: self.type.value, userId: "", pageNum: self.page)
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
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<UserRelation>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                self.noMoreData.onNext(())
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.userRelation(type: self.type.value, userId: "", pageNum: self.page)
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
        

        buttonTap.map { (cellViewModel) -> (UserRelationCellViewModel, Single<Bool>) in
            let userId = cellViewModel.item.1.userId ?? ""
            switch self.type.value {
            case .following,.followers:
                return (cellViewModel,cellViewModel.isFollow.value ? self.provider.undoFollow(userId: userId) : self.provider.follow(userId: userId))
            case .blocked:
                return (cellViewModel,cellViewModel.isFollow.value ? self.provider.undoBlocked(userId: userId) : self.provider.block(userId: userId))
            }
        }.flatMapLatest({ [weak self] (cellViewModel, request ) -> Observable<RxSwift.Event<(UserRelationCellViewModel, Bool)>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return request.trackActivity(self.loading)
                .trackError(self.error)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: { (event) in
            switch event {
            case .next(let (cellViewModel, result)):
                cellViewModel.isFollow.accept(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

            
        element.map { $0.list.map { item -> UserRelationCellViewModel in
            let cellViewModel =  UserRelationCellViewModel(item: (self.type.value,item))
                cellViewModel.buttonTap.map { cellViewModel}.bind(to: buttonTap).disposed(by: self.rx.disposeBag)
                self.type.map { $0.cellButtonNormalTitle }.bind(to: cellViewModel.buttonNormalTitle).disposed(by: self.rx.disposeBag)
                self.type.map { $0.cellButtonSelectedTitle }.bind(to: cellViewModel.buttonSelectedTitle).disposed(by: self.rx.disposeBag)
                
                return cellViewModel
            }}.bind(to: elements).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      navigationTitle: navigationTitle)
    }
}


enum UserRelationType {
    
    case followers
    case following
    case blocked
    
    var navigationTitle : String {
        switch self {
        case .followers,.following:
            return ""
        case .blocked:
            return "Blocked List"
        }
    }
    
    var cellButtonNormalTitle : String {
        switch self {
        case .followers,.following:
            return "+ Follow"
        case .blocked:
            return "Block"
        }
        
    }
    var cellButtonSelectedTitle : String {
        switch self {
        case .followers,.following:
            return "Following"
        case .blocked:
            return "Blocked"
        }
    }
}

