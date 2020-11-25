//
//  ReactionsViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReactionsViewModel: ViewModel, ViewModelType {

    struct Input {
        let selection: Observable<UsersCellViewModel>
        let footerRefresh: Observable<Void>
    }

    struct Output {
        let items: Driver<[UsersCellViewModel]>
        let heart: Driver<String>
        let haha: Driver<String>
        let wow: Driver<String>
        let sad: Driver<String>

    }

    private let item: BehaviorRelay<Insight>

    init(provider: API, item: Insight) {
        self.item = BehaviorRelay(value: item)
        super.init(provider: provider)
    }

    let element: BehaviorRelay<PageMapable<User>?> = BehaviorRelay(value: nil)

    func transform(input: Input) -> Output {

        let elements: BehaviorRelay<[UsersCellViewModel]> = BehaviorRelay(value: [])
        let buttonTap = PublishSubject<UsersCellViewModel>()
        let heart = PublishSubject<String>()
        let haha = PublishSubject<String>()
        let wow = PublishSubject<String>()
        let sad = PublishSubject<String>()

        item.map { $0.recommendId }.filterNil()
            .flatMapLatest({ [weak self] (id) -> Observable<(RxSwift.Event<PageMapable<User>>)> in
                guard let self = self else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                self.page = 1
                return self.provider.reactions(recommendId: id, pageNum: self.page)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    self.refreshState.onNext(item.refreshState)
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error {
                    default:
                        self.refreshState.onNext(.end)
                        logError(error.debugDescription)
                    }

                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        item.map { $0.recommendId }.filterNil()
            .flatMapLatest({ [weak self] (id) -> Observable<(RxSwift.Event<ReactionAnalysis>)> in
                guard let self = self else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                self.page = 1
                return self.provider.reactionAnalysis(recommendId: id)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: {  event in
                switch event {
                case .next(let item):
                    haha.onNext(item.haha.string)
                    heart.onNext(item.heart.string)
                    wow.onNext(item.wow.string)
                    sad.onNext(item.sad.string)
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error {
                    default:
                        logError(error.debugDescription)
                    }

                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<User>>> in
            guard let self = self else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            self.page += 1
            let id = self.item.value.recommendId ?? 0
            return self.provider.reactions(recommendId: id, pageNum: self.page)
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
                switch error {
                default:
                    self.page -= 1
                    self.refreshState.onNext(.end)
                    logError(error.debugDescription)
                }

            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        buttonTap.flatMapLatest({ [weak self] (cellViewModel) -> Observable<RxSwift.Event<(UsersCellViewModel, Bool)>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let userId = cellViewModel.item.model.userId ?? ""
            let request = cellViewModel.buttonSelected.value ? self.provider.undoFollow(userId: userId) :
                self.provider.follow(userId: userId)
            return request.trackActivity(self.loading)
                    .trackError(self.error)
                    .map { (cellViewModel, $0)}
                    .materialize()
        }).subscribe(onNext: { (event) in
            switch event {
            case .next(let (cellViewModel, result)):
                cellViewModel.buttonSelected.accept(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        element.filterNil().map { $0.list.map { item -> UsersCellViewModel in
            let cellViewModel =  UsersCellViewModel(item: (.reactions, item))
            cellViewModel.buttonTap.map { cellViewModel}.bind(to: buttonTap).disposed(by: self.rx.disposeBag)
            return cellViewModel
            }}.bind(to: elements).disposed(by: rx.disposeBag)

        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      heart: heart.asDriver(onErrorJustReturn: ""),
                      haha: haha.asDriver(onErrorJustReturn: ""),
                      wow: wow.asDriver(onErrorJustReturn: ""),
                      sad: sad.asDriver(onErrorJustReturn: ""))
    }
}
