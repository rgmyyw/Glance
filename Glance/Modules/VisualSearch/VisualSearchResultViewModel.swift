//
//  VisualSearchResultViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/30.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class VisualSearchResultViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<DefaultColltionSectionItem>
        let search : Observable<Void>
    }
    
    struct Output {
        let items : Driver<[VisualSearchResultSection]>
        let search : Observable<(box : Box, image : UIImage)>
        let searchHidden : Driver<Bool>
        let description : Driver<String>
        let detail : Driver<DefaultColltionItem>
    }
    
    private let image : BehaviorRelay<UIImage>
    private let element : BehaviorRelay<VisualSearchPageMapable?> = BehaviorRelay(value: nil)
    
    let imageURI = BehaviorRelay<String?>(value: nil)
    let current : BehaviorRelay<Box> = BehaviorRelay<Box>(value: .zero)
    let bottomViewHidden : BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    let searchSelection = PublishSubject<(box : Box, item : DefaultColltionItem)>()
    let dots = BehaviorRelay<[VisualSearchDotCellViewModel]>(value: [])
    let mode : BehaviorRelay<VisualSearchMode>

    init(provider: API, image : UIImage, mode : VisualSearchMode) {
        self.image = BehaviorRelay(value: image)
        self.mode = BehaviorRelay(value: mode)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        
        let imageId : BehaviorRelay<String?> = BehaviorRelay(value: nil)
        let elements = BehaviorRelay<[VisualSearchResultSection]>(value: [])
        let search = input.search.map { (box : self.current.value ,image : self.image.value ) }
        let searchHidden = mode.map { $0.searchHidden }
        let description = mode.map { $0.descriptionTitle }
        let save = PublishSubject<DefaultColltionCellViewModel>()
        let updateSelection = PublishSubject<DefaultColltionCellViewModel>()
        let detail = PublishSubject<DefaultColltionItem>()
        
        dots.map { $0.compactMap { $0.selected }}.map { $0.isEmpty}.bind(to: bottomViewHidden).disposed(by: rx.disposeBag)
        
        let refresh = current.filter { $0 != .zero }
            .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
        refresh.mapToVoid()
            .subscribe(onNext: { [weak self] () in
                self?.refreshState.onNext(.begin)
            }).disposed(by: rx.disposeBag)

        imageURI.filterNil().flatMapLatest({ [weak self] (uri) -> Observable<(RxSwift.Event<VisualSearchPageMapable>)> in
            guard let self = self else { return .error(ExceptionError.unknown) }
            var param = [String : Any]()
            param["page"] = 1
            param["limit"] = 1
            param["imUri"] = uri
            return self.provider.visualSearch(params: param)
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                imageId.accept(item.imId)
                let items = item.boxes.map { VisualSearchDotCellViewModel(box: $0,image: self.image.value)}
                items.first?.current = items.first?.box
                self.dots.accept(items)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        Observable.combineLatest(input.headerRefresh.map { self.current.value }
            .merge(with: refresh), imageId.filterNil())
            .flatMapLatest({ [weak self] (box, imageId) -> Observable<(Event<VisualSearchPageMapable>)> in
                guard let self = self  else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                guard box != .zero else {
                    return .error(ExceptionError.general("box is zero"))
                }
                guard self.element.value?.boxProducts.first?.box != box  else {
                    return Observable.just(.error(ExceptionError.general("Repeat operation")))
                }
                elements.accept([])
                self.page = 1
                var param = [String : Any]()
                param["page"] = self.page
                param["limit"] = 10
                param["box"] = box.intArray
                param["imId"] = imageId
                return self.provider.visualSearch(params: param)
                    .trackActivity(self.headerLoading)
                    .trackError(self.error)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    elements.accept([])
                    self.element.accept(item)
                    self.refreshState.onNext(item.boxProducts[0].refreshState)
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
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<Event<VisualSearchPageMapable>> in
            guard let self = self else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            self.page += 1
            let box = self.current.value.intArray
            var param = [String : Any]()
            param["page"] = self.page
            param["limit"] = 10
            param["box"] = box
            param["imId"] = imageId.value
            return self.provider.visualSearch(params: param)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = self.element.value
                let items = (temp?.boxProducts[0].productList ?? []) + item.boxProducts[0].productList
                temp?.boxProducts[0].productList = items
                self.element.accept(temp)
                self.refreshState.onNext(item.boxProducts[0].refreshState)
                
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
        
        NotificationCenter.default.rx
            .notification(.kAddProduct)
            .subscribe(onNext: { [weak self] noti in
                guard let (box, home) = noti.object as? (Box, DefaultColltionItem) else { return }
                let boxes = self?.element.value?.boxes ?? []
                if let boxIndex = boxes.firstIndex(where:  { $0 == box}) , var boxProduct = self?.element.value?.boxProducts[boxIndex] {
                    boxProduct.productList.insert(home, at: 0)
                    var element = self?.element.value
                    element?.boxProducts[boxIndex] = boxProduct
                    self?.element.accept(element)
                    self?.message.onNext(.init("add product successfully"))
                } else {
                    print("not found box")
                }
            }).disposed(by: rx.disposeBag)
        
        
        
        element.filterNil().map { (element) -> [VisualSearchResultSection] in
            guard var items = element.boxProducts.first?.productList else { return [] }
            
            /// 过滤已经选中的商品
            /// 除了当前点，选中的商品，全部剔除
            let dots = self.dots.value
            let current = self.current.value
            let selected = dots.filter { $0.box == current }.first?.selected
            let other = dots.filter { $0.box != current }.compactMap { $0.selected }
            items.removeAll(where: { other.map { $0.productId }.contains($0.productId)})
            
            /// 生成cell
            let sectionItems = items.map { item -> DefaultColltionSectionItem  in
                let viewModel = DefaultColltionCellViewModel(item: item)
                viewModel.save.map { _ in  viewModel }.bind(to: save).disposed(by: self.rx.disposeBag)
                viewModel.selected.accept(item == selected)
                return viewModel.makeItemType()
            }
            let section = self.mode.value == .preview ?
                VisualSearchResultSection.preview(items: sectionItems):
                VisualSearchResultSection.picker(items: sectionItems)
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

        
        searchSelection.delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (box, model) in
                guard let self = self else { return }
                guard let boxes = self.element.value?.boxProducts else { return  }
                guard let boxIndex = boxes.firstIndex(where: { $0.box == box})  else { return }
                guard !boxes[boxIndex].productList.contains(model) else { return }
                var item =  boxes[boxIndex]
                item.productList.insert(model, at: 0)
                var element = self.element.value
                element?.boxProducts[boxIndex] = item
                elements.accept([])
                self.element.accept(element)
                
            }).disposed(by: rx.disposeBag)
    
        
        input.selection.subscribe(onNext: { [weak self] selection in
            guard let mode = self?.mode.value else { return }
            switch mode {
            case .preview:
                detail.onNext(selection.viewModel.item)
            case .post:
                updateSelection.onNext(selection.viewModel)
            }
        }).disposed(by: rx.disposeBag)
        
        updateSelection.subscribe(onNext: { (viewModel) in
            let current = self.current.value
            let viewModels = elements.value.map { $0.items }.flatMap { $0 }.map { $0.viewModel }
            let selected = !viewModel.selected.value
            let item = viewModel.item
            var dots = self.dots.value
            
            viewModels.forEach { $0.selected.accept(false)}
            viewModel.selected.accept(selected)
            var dot = self.dots.value.filter { $0.box == current }.first
            if dot == nil {
                dot = VisualSearchDotCellViewModel(box: current, image: self.image.value)
                dot?.current = current
                dots.append(dot!)
            }
            dot?.selected = selected ? item : nil
            self.dots.accept(dots)
        }).disposed(by: rx.disposeBag)
            
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      search: search,
                      searchHidden: searchHidden.asDriver(onErrorJustReturn: true),
                      description: description.asDriver(onErrorJustReturn: ""),
                      detail: detail.asDriverOnErrorJustComplete())
    }
}
