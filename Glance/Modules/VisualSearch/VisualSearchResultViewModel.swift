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
        let selection : Observable<VisualSearchResultSectionItem>
        let search : Observable<Void>
    }
    
    struct Output {
        let items : Driver<[VisualSearchResultSection]>
        let search : Observable<(box : Box, image : UIImage)>
        
    }
    
    private let image : BehaviorRelay<UIImage>
    private let element : BehaviorRelay<VisualSearchPageMapable?> = BehaviorRelay(value: nil)
    
    let imageURI = BehaviorRelay<String?>(value: nil)
    let currentBox : BehaviorRelay<Box> = BehaviorRelay<Box>(value: .zero)
    let selected : BehaviorRelay<[(box : Box, item : Home)]> = BehaviorRelay(value: [])
    let bottomViewHidden : BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    let searchSelection = PublishSubject<(box : Box, item : Home)>()
    let updateBox = PublishSubject<[(Bool,Box)]>()
    
    
    
    init(provider: API, image : UIImage) {
        self.image = BehaviorRelay(value: image)
        super.init(provider: provider)
    }
    
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[VisualSearchResultSection]>(value: [])
        let selected = BehaviorRelay<[(box : Box, item : Home)]>(value:[])
        let search = input.search.map { (box : self.currentBox.value ,image : self.image.value ) }
        selected.map { $0.isEmpty }.bind(to: bottomViewHidden).disposed(by: rx.disposeBag)
        selected.bind(to: self.selected).disposed(by: rx.disposeBag)
        
        
        func makeBoxAction() -> [(Bool,Box)] {
            guard let boxes = self.element.value?.boxProducts else { return [] }
            return boxes.compactMap { item -> (Bool, Box)? in
                guard let box = item.box else { return nil }
                if item.system {
                    //print("当前是系统 box :\(box)")
                    if selected.value.contains(where: { $0.box == box } ) {
                        //print("并且包含在选中的数组中")
                        return (true, box)
                    } else {
                        //print("并且没有在选中的数组中")
                        return (false, box)
                    }
                } else {
                    //print("当前不是系统 box :\(box)")
                    if selected.value.contains(where: { $0.box == box }) {
                        //print("并且包含在选中的数组中")
                        return (true, box)
                    } else {
                        //print("并且没有在选中的数组中，移出当前...")
                        return nil
                    }
                }
            }
            
        }
        
        
        element.filterNil().mapToVoid().map { makeBoxAction() }.bind(to: updateBox).disposed(by: rx.disposeBag)
        
        imageURI.filterNil().delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMapLatest({ [weak self] (uri) -> Observable<(RxSwift.Event<VisualSearchPageMapable>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                elements.accept([])
                self.page = 1
                var param = [String : Any]()
                param["page"] = self.page
                param["limit"] = 10
                param["imUri"] = uri
                return self.provider.visualSearch(params: param)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    var item = item
                    item.boxProducts = item.boxProducts
                        .map { item -> BoxProducts in
                            var item = item
                            item.system = true
                            return item
                    }
                    self.element.accept(item)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        
        currentBox.filter { $0 != .zero }.flatMap { box -> Observable<Box> in
            selected.value.contains(where: { $0.box == box}) ?
                Observable.just(box) : Observable.just(box)
                    .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
        }.flatMapLatest({ [weak self] (box) -> Observable<(RxSwift.Event<(Bool,Box ,VisualSearchPageMapable, VisualSearchPageMapable)>)> in
            
            guard let self = self , let element = self.element.value else { return Observable.just(RxSwift.Event.completed) }
            if let index = element.boxes.firstIndex(where: { $0 == box })   {
                let item = VisualSearchPageMapable(boxProduct: element.boxProducts[index])
                let event = RxSwift.Event.next((true,box, element, item))
                return Observable.just(event)
            }
            
            self.page = 1
            var param = [String : Any]()
            param["page"] = self.page
            param["limit"] = 10
            param["imId"] = element.imId ?? ""
            param["box"] = box.toIntArray()
            return self.provider.visualSearch(params: param)
                .trackError(self.error)
                .map { (false,box, element, $0)}
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next(let (exists , _, element, result)):
                guard !exists  else {
                    self.element.accept(element)
                    return
                }
                
                var element = element
                element.boxProducts.append(result.boxProducts[0])
                self.element.accept(element)
                self.hasData.onNext(result.boxProducts[0].hasNext)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<(Int, VisualSearchPageMapable)>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            guard let index = self.element.value?.boxes.firstIndex(where: { $0 == self.currentBox.value }) ,
                let element =  self.element.value?.boxProducts[index] ,element.hasNext  else {
                    return Observable.just(RxSwift.Event.completed)
            }
            
            self.page += 1
            var param = [String : Any]()
            param["page"] = self.page
            param["limit"] = 10
            param["imId"] = self.element.value?.imId ?? ""
            
            return self.provider.visualSearch(params: param)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .map { (index,$0)}
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let (index, item)):
                var element = self.element.value
                element?.boxProducts[index].productList.append(contentsOf: item.boxProducts[0].productList)
                self.element.accept(element)
                
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.map { $0?.boxes }.map { $0?.firstIndex { $0 == self.currentBox.value } }.filterNil().map { (boxIndex) -> [VisualSearchResultSection] in
            
            guard let boxProducts = self.element.value?.boxProducts , boxIndex < boxProducts.count  else { return [] }
            
            let element = boxProducts[boxIndex]
            let box = element.box
            var items = element.productList
            
            /// 如果当前已选中的数组中 包含当前的box, 进行更新选中状态
            let exist = selected.value.map { $0.box }.contains(where:  { $0 == box})
            
            /// 过滤已经选中的商品
            var x = selected.value
            x.removeAll(where: { $0.box == box})
            items.removeAll(where: { x.map { $0.item.productId }.contains($0.productId)})
            
            
            let sectionId = box?.string ?? ""
            
            /// 生成cell
            let sectionItems = items.enumerated().map { (offset, item) -> VisualSearchResultSectionItem  in
                let viewModel = VisualSearchResultCellViewModel(item: item)
                let item = VisualSearchResultSectionItem(item: "\(sectionId)-\(offset)-\((item.productId ?? offset.string))", viewModel: viewModel)
                return item
            }
            
            /// 存在的, 取出对应的box , 更新选中状态
            if exist , let index = selected.value.firstIndex(where: { $0.box == box}){
                for current in sectionItems {
                    if current.viewModel.item == selected.value[index].item {
                        current.viewModel.selected.accept(true)
                        break
                    }
                }
            }
            
            return [VisualSearchResultSection(section: sectionId, elements: sectionItems)]
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
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
            guard let self = self else { return }
            guard let boxes = self.element.value?.boxProducts else { return  }
            guard let boxIndex = boxes.firstIndex(where: { $0.box == self.currentBox.value}) , let box = boxes[boxIndex].box else { return }
            
            let items = elements.value.map { $0.items }.flatMap { $0 }
            let viewModels = items.map { $0.viewModel }
            
            if selection.viewModel.selected.value ,let index = selected.value.firstIndex(where: { $0.box == box } )  {
                
                selection.viewModel.selected.accept(false)
                var values = selected.value
                values.remove(at: index)
                selected.accept(values)
                
            } else {
                
                viewModels.forEach { $0.selected.accept(false)}
                selection.viewModel.selected.accept(true)
                var values = selected.value
                if let index = selected.value.firstIndex(where: { $0.box == box } ) {
                    values.remove(at: index)
                }
                selected.accept(values + [(box, selection.viewModel.item)])
            }
            
            self.updateBox.onNext(makeBoxAction())
            
        }).disposed(by: rx.disposeBag)
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []), search: search)
    }
}
