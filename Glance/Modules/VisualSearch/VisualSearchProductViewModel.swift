//
//  VisualSearchProductViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class VisualSearchProductViewModel: ViewModel, ViewModelType {
        
    struct Input {
        let search: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<VisualSearchProductSectionItem>
        let add : Observable<Void>
    }
    
    struct Output {
        let items : Driver<[VisualSearchProductSection]>
        let add : Observable<(box : Box, image: UIImage)>
    }
    
    
    let textInput = BehaviorRelay<String>(value: "")
    let element : BehaviorRelay<PageMapable<DefaultColltionItem>?> = BehaviorRelay(value: nil)
    let selected = PublishSubject<(box : Box, item : DefaultColltionItem)>()
    
    let image : BehaviorRelay<UIImage>
    let currentBox : BehaviorRelay<Box>
    
    init(provider: API, image : UIImage, box : Box) {
        self.image = BehaviorRelay(value: image)
        self.currentBox = BehaviorRelay(value: box)
        super.init(provider: provider)
    }

    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[VisualSearchProductSection]>(value: [])
        let add = PublishSubject<Void>()
        input.add.bind(to: add).disposed(by: rx.disposeBag)
        let addAction = add.map { (box : self.currentBox.value,image : self.image.value)}
        
        input.search.flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<DefaultColltionItem>>)> in
            guard let self = self else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            guard self.textInput.value.isNotEmpty else {
                self.exceptionError.onNext(.general("Please enter the search keyword"))
                return Observable.just(.error(ExceptionError.unknown))
            }
            
            elements.accept([])
            self.endEditing.onNext(())
            self.page = 1
            let text = self.textInput.value
            return self.provider.productSearch(type: .inApp, keywords: text, page: self.page)
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
            let text = self.textInput.value
            return self.provider.productSearch(type: .inApp, keywords: text, page: self.page)
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
        
        
        element.filterNil().map { element -> [VisualSearchProductSection] in
            let sectionItems = element.list.enumerated().map { (indexPath, item) -> VisualSearchProductSectionItem in
                let cellViewModel = VisualSearchProductCellViewModel(item: item)
                let sectionItem = VisualSearchProductSectionItem(item: indexPath, viewModel: cellViewModel)
                return sectionItem
            }
            let empty = VisualSearchProductEmptyCellModel(item: ())
            empty.add.bind(to: add).disposed(by: self.rx.disposeBag)
            let section = VisualSearchProductSection(section: 0, elements: sectionItems, viewModel: empty)
            return [section]
            
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        input.selection
            .subscribe(onNext: { [weak self](item) in
                guard let self = self else { return }
                self.selected.onNext((self.currentBox.value, item.viewModel.item))
        }).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []), add: addAction)
    }
}
