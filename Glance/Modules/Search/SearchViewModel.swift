//
//  SearchViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewModel: ViewModel, ViewModelType {

    struct Input {
        let cancel: Observable<Void>
        let selection: Observable<SearchCellViewModel>
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let textFieldReturn: Observable<Void>
        let camera: Observable<Void>

    }

    struct Output {
        let items: Driver<[SearchCellViewModel]>
        let search: Driver<String>
        let close: Driver<Void>
        let viSearch: Driver<Void>
    }

    public let selection = PublishSubject<String>()
    public let text: BehaviorRelay<String>

    private let source: BehaviorRelay<String>
    private let element: BehaviorRelay<[SearchFacet]> = BehaviorRelay(value: [])

    init(provider: API, text: String = "") {
        self.source = BehaviorRelay(value: text)
        self.text = BehaviorRelay(value: text)
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {

        let elements: BehaviorRelay<[SearchCellViewModel]> = BehaviorRelay(value: [])
        let complete = PublishSubject<String>()
        let close = PublishSubject<String>()
        let search = PublishSubject<String>()

        close.filter { $0 != self.source.value }.bind(to: selection).disposed(by: rx.disposeBag)
        input.cancel.map { self.source.value }.bind(to: close).disposed(by: rx.disposeBag)

        complete.subscribe(onNext: { [weak self](text) in
            let source = self?.source.value
            SearchHistoryItem(text: text).save()
            if let s = source, s.isNotEmpty {
                close.onNext(text)
            } else {
                search.onNext(text)
            }
        }).disposed(by: rx.disposeBag)

        text.filterEmpty()
            .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .flatMapLatest({ [weak self] (text) -> Observable<(RxSwift.Event<[SearchFacet]>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                return self.provider.searchFacets(query: text)
                    .trackError(self.error)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        element.map { $0.map { item -> SearchCellViewModel in
            let cellViewModel = SearchCellViewModel(item: (self.text.value, item))
                return cellViewModel
            }}.bind(to: elements).disposed(by: rx.disposeBag)

        input.textFieldReturn.map { self.text.value }
            .merge(with: input.selection.map { $0.item.target.facets })
            .filterNil().bind(to: complete)
            .disposed(by: rx.disposeBag)

        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      search: search.asDriver(onErrorJustReturn: ""),
                      close: close.mapToVoid().asDriver(onErrorJustReturn: ()),
                      viSearch: input.camera.asDriverOnErrorJustComplete())
    }
}
