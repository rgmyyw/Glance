//
//  StyleBoardSearchContentViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/10/26.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class StyleBoardSearchContentViewModel: ViewModel, ViewModelType {

    struct Input {
        let footerRefresh: Observable<Void>
        let selection: Observable<StyleBoardSearchSectionItem>
        let upload: Observable<Void>
    }

    struct Output {
        let items: Driver<[StyleBoardSearchSection]>
    }

    let element: BehaviorRelay<PageMapable<DefaultColltionItem>?> = BehaviorRelay(value: nil)
    let selection = PublishSubject<[DefaultColltionItem]>()
    let textInput = BehaviorRelay<String>(value: "")
    let type: BehaviorRelay<Int>
    let upload = PublishSubject<Void>()

    init(provider: API, type: Int) {
        self.type = BehaviorRelay(value: type)
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {

        let elements = BehaviorRelay<[StyleBoardSearchSection]>(value: [])

        input.upload.bind(to: upload).disposed(by: rx.disposeBag)

        textInput.debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .map { $0.trimmingCharacters(in: .whitespaces)}
            .filterEmpty()
            .flatMapLatest({ [weak self] (text) -> Observable<(RxSwift.Event<PageMapable<DefaultColltionItem>>)> in
                elements.accept([])
                guard let self = self, let type = ProductSearchType(rawValue: self.type.value) else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                self.page = 1
                return self.provider.productSearch(type: type, keywords: text, page: self.page)
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
                    switch error {
                    default:
                        self.refreshState.onNext(.end)
                        logError(error.debugDescription)
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<DefaultColltionItem>>> in
            guard let self = self, let type = ProductSearchType(rawValue: self.type.value) else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            self.page += 1
            let text = self.textInput.value
            return self.provider.productSearch(type: type, keywords: text, page: self.page)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = (self.element.value?.list ?? [] ) + item.list
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

        element.filterNil().map { element -> [StyleBoardSearchSection] in
            let sectionItems = element.list.enumerated().map { (indexPath, item) -> StyleBoardSearchSectionItem in
                let cellViewModel = StyleBoardSearchCellViewModel(item: item)
                let sectionItem = StyleBoardSearchSectionItem(item: indexPath, viewModel: cellViewModel)
                return sectionItem
            }
            let section = StyleBoardSearchSection(section: 0, elements: sectionItems)
            return [section]

        }.bind(to: elements).disposed(by: rx.disposeBag)

        input.selection.subscribe(onNext: { [weak self] item in
            item.viewModel.selected.accept(!item.viewModel.selected.value)
            let items = elements.value.flatMap { $0.items.map { $0.viewModel } }.filter { $0.selected.value }.map { $0.item }
            self?.selection.onNext(items)
        }).disposed(by: rx.disposeBag)

        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
