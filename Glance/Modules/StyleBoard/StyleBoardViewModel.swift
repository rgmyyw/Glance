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
    }
    
    struct Output {
        let items : Driver<[StyleBoardSection]>
        let add : Driver<Void>
        let nextButtonEnable : Driver<Bool>
    }
    
    let selection = PublishSubject<[Home]>()
    let selected : BehaviorRelay<[Home]> = BehaviorRelay(value: [])
    
    
    func transform(input: Input) -> Output {
        

        let elements = BehaviorRelay<[StyleBoardSection]>(value: [])
        let add = PublishSubject<Void>()
        let delete = PublishSubject<StyleBoardImageCellViewModel>()
        let nextButtonEnable = selected.map { $0.isNotEmpty }.asDriver(onErrorJustReturn: false)
                
        selection.map { ($0 + self.selected.value).filterDuplicates { $0.productId }  }
            .filterEmpty()
            .filter { $0.count != self.selected.value.count }
            .bind(to: selected).disposed(by: rx.disposeBag)

        selected.map { i -> [StyleBoardSection] in
            var elements = i.enumerated().map { (offset, item) -> StyleBoardSectionItem in
                let viewModel = StyleBoardImageCellViewModel(item: item)
                viewModel.delete.map { viewModel }.bind(to: delete).disposed(by: self.rx.disposeBag)
                let item = StyleBoardSectionItem.image(identity: viewModel.item.productId!, viewModel: viewModel)
                return item
            }
            let emptyViewModel = StyleBoardImageCellViewModel(item: Home(productId: "-1"))
            let empty = StyleBoardSectionItem.image(identity: "-1", viewModel: emptyViewModel)
            emptyViewModel.add.bind(to: add).disposed(by: self.rx.disposeBag)
            elements.append(empty)
            
            return [StyleBoardSection.images(items: elements)]
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        delete.subscribe(onNext: { [weak self](viewModel) in
            print("will delete productId: \(viewModel.item.productId ?? "")")
            var items = self?.selected.value ?? []
            print("current:\(items.compactMap { $0.productId }) ")
            let index = items.firstIndex { $0.productId == viewModel.item.productId }
            if let index = index{
                items.remove(at: index)
            } else {
                print("not found")
            }
            print("delete complete:\(items.compactMap { $0.productId})")
            self?.selected.accept(items)
            
        }).disposed(by: rx.disposeBag)
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      add: add.asDriver(onErrorJustReturn: ()),
                      nextButtonEnable: nextButtonEnable)
    }
}

