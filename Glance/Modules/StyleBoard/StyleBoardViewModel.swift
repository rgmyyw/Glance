//
//  StyleBoardViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class StyleBoardViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let next : Observable<Void>
        let selection : Observable<StyleBoardImageCellViewModel>
    }
    
    struct Output {
        let items : Driver<[StyleBoardSection]>
        let add : Driver<Void>
        let nextButtonEnable : Driver<Bool>
        let generateImage : Driver<Void>
        let post : Driver<(image : UIImage, items : [DefaultColltionItem])>
        

    }
    
    let selection = PublishSubject<[DefaultColltionItem]>()
    let element : BehaviorRelay<[DefaultColltionItem]> = BehaviorRelay(value: [])
    let image = PublishSubject<UIImage>()
    let reselection = PublishSubject<DefaultColltionItem>()
    
    func transform(input: Input) -> Output {

        let elements = BehaviorRelay<[StyleBoardSection]>(value: [])
        let add = PublishSubject<Void>()
        let delete = PublishSubject<StyleBoardImageCellViewModel>()
        let nextButtonEnable = element.map { $0.isNotEmpty }
        

        
        let post = image.map { image -> (image : UIImage, items : [DefaultColltionItem]) in
            let values = self.element.value
            return (image, values)
        }
                
        selection.map { ($0 + self.element.value).filterDuplicates { $0.productId }  }
            .filterEmpty()
            .filter { $0.count != self.element.value.count }
            .bind(to: element).disposed(by: rx.disposeBag)

        element.map { i -> [StyleBoardSection] in
            
            var elements = i.enumerated().map { (offset, item) -> StyleBoardSectionItem in
                let viewModel = StyleBoardImageCellViewModel(item: item)
                viewModel.delete.map { viewModel }.bind(to: delete).disposed(by: self.rx.disposeBag)
                let item = StyleBoardSectionItem.image(identity: viewModel.item.productId!, viewModel: viewModel)
                return item
            }
            let emptyViewModel = StyleBoardImageCellViewModel(item: DefaultColltionItem(productId: ""))
            let empty = StyleBoardSectionItem.image(identity: "", viewModel: emptyViewModel)
            emptyViewModel.add.bind(to: add).disposed(by: self.rx.disposeBag)
            elements.append(empty)

            return [StyleBoardSection.images(items: elements)]
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        delete.subscribe(onNext: { [weak self](viewModel) in
            print("will delete productId: \(viewModel.item.productId ?? "")")
            var items = self?.element.value ?? []
            print("current:\(items.compactMap { $0.productId }) ")
            let index = items.firstIndex { $0.productId == viewModel.item.productId }
            if let index = index{
                items.remove(at: index)
            } else {
                print("not found")
            }
            print("delete complete:\(items.compactMap { $0.productId})")
            self?.element.accept(items)
            
        }).disposed(by: rx.disposeBag)
        
        /// 用户手动添加商品
        NotificationCenter.default.rx
            .notification(.kAddProduct)
            .map { $0.object as? (Box, DefaultColltionItem)}
            .filterNil()
            .map { [$0.1] }.bind(to: selection).disposed(by: rx.disposeBag)
        
        input.selection
            .subscribe(onNext: { (cellViewModel) in
                elements.value.first?.items.forEach { $0.viewModel.selected.accept(false)}
                cellViewModel.selected.accept(true)
        }).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      add: add.asDriver(onErrorJustReturn: ()),
                      nextButtonEnable: nextButtonEnable.asDriver(onErrorJustReturn: false),
                      generateImage: input.next.asDriverOnErrorJustComplete(),
                      post: post.asDriverOnErrorJustComplete())
    }
}

