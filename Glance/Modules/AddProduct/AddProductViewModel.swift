//
//  AddProductViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddProductViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let selection : Observable<AddProductSectionItem>
    }
    
    struct Output {
        let items : Driver<[AddProductSection]>
        let selectionCategory : Driver<[Categories]>
        let detail : Driver<String>
    }
    
    let selectedCategory = PublishSubject<Categories>()
    
    let image : BehaviorRelay<UIImage>
    
    init(provider: API, image : UIImage) {
        self.image = BehaviorRelay(value: image)
        super.init(provider: provider)
    }
    
    
    func transform(input: Input) -> Output {
        
        let element = BehaviorRelay<[Categories]>(value: [])
        let elements = BehaviorRelay<[AddProductSection]>(value: [])
        let selectionCategory = PublishSubject<[Categories]>()
        let addTag = PublishSubject<String>()
        let deleteTag = PublishSubject<AddProductSectionItem>()
        let commitButtonTap = PublishSubject<Void>()
        let uploadImage = PublishSubject<(UIImage, [String : Any])>()
        let commit = PublishSubject<[String : Any]>()
        let edit = PublishSubject<AddProductImageCellViewModel>()
        let detail = PublishSubject<String>()
        
        
        Observable.just(()).flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<[Categories]>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.categories()
                .trackActivity(self.loading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { event in
            switch event {
            case .next(let items):
                element.accept(items)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        commit.flatMapLatest({ [weak self] (param) -> Observable<(RxSwift.Event<String>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.addProduct(param: param)
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: {  event in
            switch event {
            case .next(let productId):
                detail.onNext(productId)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        element.filterEmpty().map { items -> [AddProductSection] in
            
            let viewModel = AddProductSectionCellViewModel(item: items)
            viewModel.selectionCategory.map { viewModel.item }.bind(to: selectionCategory).disposed(by: self.rx.disposeBag)
            viewModel.addTag.bind(to: addTag).disposed(by: self.rx.disposeBag)
            viewModel.commit.bind(to: commitButtonTap).disposed(by: self.rx.disposeBag)
            self.selectedCategory.bind(to: viewModel.selectedCategory).disposed(by: self.rx.disposeBag)
            
            let tagItems = (1..<4).map { number ->  AddProductSectionItem in
                let viewModel = AddProductTagCellViewModel(item: "\(number) : \(String.random(ofLength: Int.random(in: 0...10)))")
                let item = AddProductSectionItem.tag(identity: number.string,viewModel: viewModel)
                viewModel.delete.map { item }.bind(to: deleteTag).disposed(by: self.rx.disposeBag)
                return item
            }
                        
            let imageItem = AddProductImageCellViewModel(item: self.image.value)
            imageItem.edit.map { imageItem }.bind(to: edit).disposed(by: self.rx.disposeBag)
            let image = AddProductSectionItem.thumbnail(identity: String.random(ofLength: Int.random(in: 0..<10)),viewModel: imageItem)

            let name = AddProductSection.productName(viewModel: viewModel)
            let categary = AddProductSection.categary(viewModel: viewModel)
            let inputKeyword = AddProductSection.tagRelatedKeywords(viewModel: viewModel)
            let tags = AddProductSection.tags(items: tagItems)
            let brand = AddProductSection.brand(viewModel: viewModel)
            let website = AddProductSection.website(viewModel: viewModel)
            let thumbnail = AddProductSection.thumbnail(items: [image])
            let button = AddProductSection.button(viewModel: viewModel)
            
            return [name, categary,inputKeyword,tags,brand,website,thumbnail,button]
            
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        
        addTag.subscribe(onNext: { (text) in
            self.endEditing.onNext(())
            var sections = elements.value
            let section = sections[3]
            var items = section.items
            
            let viewModel = AddProductTagCellViewModel(item: text)
            let item = AddProductSectionItem.tag(identity: (items.count + 1).string,viewModel: viewModel)
            viewModel.delete.map { item }.bind(to: deleteTag).disposed(by: self.rx.disposeBag)
            
            items.insert(item, at: 0)
            let new = AddProductSection.tags(items: items)
            sections[3] = new
            elements.accept(sections)
        }).disposed(by: rx.disposeBag)
        
        
        deleteTag.subscribe(onNext: { (item) in
            self.endEditing.onNext(())
            var sections = elements.value
            let section = sections[3]
            var items = section.items
            items.removeAll(item)
            let new = AddProductSection(original: section, items: items)
            sections[3] = new
            elements.accept(sections)
        }).disposed(by: rx.disposeBag)
        
        uploadImage.flatMapLatest({ [weak self] (imageData,param) -> Observable<(RxSwift.Event<(String, [String : Any])>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            guard let data = imageData.jpegData(compressionQuality: 0.1) else { return  Observable.just(RxSwift.Event.completed) }
            return self.provider.uploadImage(type: UploadImageType.post.rawValue, size: imageData.size, data: data)
                .trackActivity(self.loading)
                .trackError(self.error)
                .map { ($0,param)}
                .materialize()
        }).subscribe(onNext: { event in
            switch event {
            case .next(let (url, param)):
                var param = param
                param["imUri"] = url
                commit.onNext(param)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        commitButtonTap.subscribe(onNext: { [weak self] () in
            
            let viewModel = elements.value.first?.viewModel
            let thumbnail = elements.value[6].items
            let tags = elements.value[3].items
            
            guard let productName = viewModel?.productName.value, productName.count > 5 else {
                self?.exceptionError.onNext(.general(message: "productName minimum of 6"))
                return
            }
            
            guard let categoryId = viewModel?.selectedCategory.value?.categoryId  else {
                self?.exceptionError.onNext(.general(message: "choose category"))
                return
            }
            
            guard let brand = viewModel?.brand.value  else {
                self?.exceptionError.onNext(.general(message: "brand minimum of 2"))
                return
            }
            
            guard let website = viewModel?.website.value  else {
                self?.exceptionError.onNext(.general(message: "input website not correct"))
                return
            }
            
            guard case let .thumbnail(_, imageItem) = thumbnail.first , let image = imageItem.image.value  else {
                self?.exceptionError.onNext(.general(message: "not found image"))
                return
            }
            
            let tag = tags.compactMap { $0.viewModel(AddProductTagCellViewModel.self).title.value }    
            
            var param = [String : Any]()
            param["productName"] = productName
            param["categoryId"] = categoryId
            param["brand"] = brand
            param["website"] = website
            param["tags"] = tag
            uploadImage.onNext((image, param))
            
        }).disposed(by: rx.disposeBag)
        
        edit.subscribe(onNext: { [weak self](cellViewModel) in
            self?.message.onNext(.init("click image edit"))
        }).disposed(by: rx.disposeBag)
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      selectionCategory : selectionCategory.asDriver(onErrorJustReturn: []),
                      detail: detail.asDriver(onErrorJustReturn: ""))
    }
}

