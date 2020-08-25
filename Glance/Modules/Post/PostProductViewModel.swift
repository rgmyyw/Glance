//
//  PostProductViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostProductViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let selection : Observable<PostProductSectionItem>
        let commit : Observable<Void>
    }
    
    struct Output {
        let items : Driver<[PostProductSection]>
        let detail : Driver<String>
        let navigationImage : Driver<UIImage?>
        let complete : Driver<Void>
    }
    
    let items : BehaviorRelay<[(box : Box, item : Home)]>
    
    let currentImage : BehaviorRelay<UIImage?>
    let edit = PublishSubject<(box : Box, item : Home )>()
    
    
    init(provider: API, image : UIImage?, taggedItems : [(Box,Home)] ) {
        self.currentImage = BehaviorRelay(value: image)
        self.items = BehaviorRelay(value: taggedItems)
        super.init(provider: provider)
    }
    
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[PostProductSection]>(value: [])
        let addTag = PublishSubject<String>()
        let uploadImage = PublishSubject<(UIImage, [String : Any])>()
        let commit = PublishSubject<[String : Any]>()
        let detail = PublishSubject<String>()
        let tagAction = PublishSubject<(PostProductSectionItem , PostProductTagStyle.PostProductTagStyleAction)>()
        let navigationImage = currentImage.asDriver(onErrorJustReturn: nil)
        let complete = PublishSubject<Void>()
        
        
        
        Observable.just(()).map { () ->  [PostProductSection] in
            
            let viewModel = PostProductSectionCellViewModel(item: ())
            viewModel.addTag.bind(to: addTag).disposed(by: self.rx.disposeBag)
            
//            let customTagsItems = (1..<5).map { number ->  PostProductSectionItem in
//                let viewModel = PostProductTagCellViewModel(item: "\(number) : \(String.random(ofLength: Int.random(in: 0...10)))")
//                viewModel.style.accept(.custom)
//                viewModel.selected.accept(true)
//                let item = PostProductSectionItem.tag(identity: "section1-item\(number)",viewModel: viewModel)
//                viewModel.action.map { (item,$0)}.bind(to: tagAction).disposed(by: self.rx.disposeBag)
//                return item
//            }
            
//            let systemTagsItems = (1..<5).map { number ->  PostProductSectionItem in
//                let viewModel = PostProductTagCellViewModel(item: "\(number) : \(String.random(ofLength: Int.random(in: 0...10)))")
//                viewModel.style.accept(.system)
//                viewModel.selected.accept(false)
//                let item = PostProductSectionItem.tag(identity: "section2-item\(number)",viewModel: viewModel)
//                viewModel.action.map { (item,$0)}.bind(to: tagAction).disposed(by: self.rx.disposeBag)
//                return item
//            }
            
            let taggedItem = self.items.value.enumerated().map { (offset, item) ->  PostProductSectionItem in
                let viewModel = PostProductCellViewModel(item: item)
                viewModel.edit.map { viewModel.item }.bind(to: self.edit).disposed(by: self.rx.disposeBag)
                let item = PostProductSectionItem.product(identity: "section3-item\(offset)", viewModel: viewModel)
                return item
            }
            
            let caption = PostProductSection.caption(viewModel: viewModel)
//            let inputKeyword = PostProductSection.tagRelatedKeywords(viewModel: viewModel)
//            let customTags = PostProductSection.customTags(items: customTagsItems)
//            let systemTags = PostProductSection.systemTags(title: "Keyword suggestion", items: systemTagsItems)
            let tagged = PostProductSection.tagged(title: "Tagged items", items: taggedItem)
            //return [caption,inputKeyword,customTags,systemTags,tagged]
            return [caption,tagged]

            
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        
        commit.flatMapLatest({ [weak self] (param) -> Observable<(RxSwift.Event<Bool>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.postProduct(param: param)
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { event in
            switch event {
            case .next(let result):
                if result {
                    complete.onNext(())
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        addTag.subscribe(onNext: { (text) in
            self.endEditing.onNext(())
            var sections = elements.value
            let section = sections[2]
            var items = section.items
            
            let viewModel = PostProductTagCellViewModel(item: text)
            viewModel.style.accept(.custom)
            viewModel.selected.accept(true)
            let item = PostProductSectionItem.tag(identity: "section2-item\(items.count + 1000)",viewModel: viewModel)
            viewModel.action.map { (item,$0)}.bind(to: tagAction).disposed(by: self.rx.disposeBag)
            
            items.insert(item, at: 0)
            let new = PostProductSection.customTags(items: items)
            sections[2] = new
            elements.accept(sections)
        }).disposed(by: rx.disposeBag)

        tagAction.subscribe(onNext: { (item, action)in
            switch action {
            case .delete:
                var sections = elements.value
                let section = sections[2]
                var items = section.items
                items.removeAll(item)
                let new = PostProductSection.customTags(items: items)
                sections[2] = new
                elements.accept(sections)
            case .state(let state):
                item.viewModel(PostProductTagCellViewModel.self).selected.accept(state)
            }
            
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
                param["imageUri"] = url
                commit.onNext(param)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
                
        Observable.combineLatest(input.commit, currentImage.filterNil())
            .subscribe(onNext: { [weak self] (_, image) in
                self?.endEditing.onNext(())
                let viewModel = elements.value.first?.viewModel
                
//                let customTags = elements.value[2].items.map { $0.viewModel(PostProductTagCellViewModel.self)}
//                let systemTags = elements.value[3].items.map { $0.viewModel(PostProductTagCellViewModel.self)}
                let taggedItems = elements.value.last?.items.map { $0.viewModel(PostProductCellViewModel.self)}
                guard let caption = viewModel?.caption.value, caption.isNotEmpty else {
                    self?.exceptionError.onNext(.general("caption is empty"))
                    return
                }
                
//                guard let custom = customTags  else {
//                    self?.exceptionError.onNext(.general("customTags is empty"))
//                    return
//                }
//
//                guard let system = systemTags else {
//                    self?.exceptionError.onNext(.general("systemTags is empty"))
//                    return
//                }
                
                guard let tagged = taggedItems else {
                    self?.exceptionError.onNext(.general("You must select a tagged item"))
                    return
                }
                
                let productIds = tagged.compactMap { $0.item.item.productId }.joined(separator: ",")
                //let tags = (custom + system).compactMap { $0.item }.joined(separator: ",")
                var param = [String : Any]()
                param["title"] = caption
                //param["tags"] = tags
                param["productIds"] = productIds
                
                uploadImage.onNext((image, param))
                
            }).disposed(by: rx.disposeBag)
        
        
        items.filter {_ in elements.value.isNotEmpty }
            .map { items -> [PostProductSectionItem] in
                return items.enumerated().map { (offset, model) ->  PostProductSectionItem in
                    let viewModel = PostProductCellViewModel(item: model)
                    viewModel.edit.map { viewModel.item }.bind(to: self.edit).disposed(by: self.rx.disposeBag)
                    let item = PostProductSectionItem.product(identity: "section3-item\(offset)", viewModel: viewModel)
                    return item
                }
        }.subscribe(onNext: { items in
            
            let last = elements.value.count - 1
            var sections = elements.value
            let section = sections[last]
            sections[last] = PostProductSection(original: section, items: items)
            elements.accept(sections)
            
        }).disposed(by: rx.disposeBag)
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      detail: detail.asDriver(onErrorJustReturn: ""),
                      navigationImage: navigationImage,
                      complete: complete.asDriver(onErrorJustReturn: ()))
    }
}


