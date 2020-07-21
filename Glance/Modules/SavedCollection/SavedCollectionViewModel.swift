//
//  SavedCollectionViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SavedCollectionViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<SavedCollectionCellViewModel>
        let edit : Observable<Bool>
        let back : Observable<Bool>
    }
    
    struct Output {
        let items : Driver<[SectionModel<Void,SavedCollectionCellViewModel>]>
        let isEdit : Driver<Bool>
        let backButtonImage : Driver<UIImage?>
        let navigationTitle : Driver<String>
        let editButtonImage : Driver<UIImage?>
        let editButtonTitle : Driver<String?>
        let back : Driver<Void>
    }
    
    let element : BehaviorRelay<PageMapable<Home>> = BehaviorRelay(value: PageMapable<Home>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,SavedCollectionCellViewModel>]>(value: [])
        let isEdit = BehaviorRelay<Bool>(value: false)
        let back = PublishSubject<Void>()
        let delete = PublishSubject<SavedCollectionCellViewModel>()
        
        let navigationTitle = isEdit.map { $0 ? "Edit Collection" : "Saved Collection List" }.asDriver(onErrorJustReturn: "")
        let backButtonImage = isEdit.map { $0 ? R.image.icon_navigation_close() : R.image.icon_navigation_back_black() }.asDriver(onErrorJustReturn: nil)
        let editButtonImage = isEdit.map { $0 ? nil : R.image.icon_navigation_edit() }.asDriver(onErrorJustReturn: nil)
        let editButtonTitle = isEdit.map { $0 ? "DONE" : nil }.asDriver(onErrorJustReturn: "")
        
        
        input.edit.map { !$0 }.bind(to: isEdit).disposed(by: rx.disposeBag)
        input.back.subscribe(onNext: { i in
            if i == true {
                isEdit.accept(false)
            } else {
                back.onNext(())
            }
        }).disposed(by: rx.disposeBag)
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                isEdit.value ? isEdit.accept(false) : ()
                self.page = 1
                return self.provider.savedCollection(pageNum: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    if !item.hasNext  {
                        self.noMoreData.onNext(())
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Home>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                self.noMoreData.onNext(())
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.savedCollection(pageNum: self.page)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = self.element.value.list + item.list
                self.element.accept(temp)
                if !item.hasNext  {
                    self.noMoreData.onNext(())
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.map { items -> [SectionModel<Void,SavedCollectionCellViewModel>] in
            let sectionItems = items.list.map { item -> SavedCollectionCellViewModel  in
                let viewModel = SavedCollectionCellViewModel(item: item)
                viewModel.delete.map { viewModel }.bind(to: delete).disposed(by: self.rx.disposeBag)
                isEdit.map { !$0}.bind(to: viewModel.deleteButtonHidden).disposed(by: self.rx.disposeBag)
                return viewModel
            }
            let sections = [SectionModel<Void,SavedCollectionCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        delete.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(SavedCollectionCellViewModel,Bool)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.saveCollection(id: cellViewModel.item.id, type: cellViewModel.item.type.rawValue, state: false)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let (cellViewModel,result)):
                if !result {
                    var section = elements.value[0]
                    section.items.removeFirst(where: { $0.item == cellViewModel.item})
                    elements.accept([section])
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      isEdit: isEdit.asDriver(onErrorJustReturn: false),
                      backButtonImage: backButtonImage,
                      navigationTitle: navigationTitle,
                      editButtonImage: editButtonImage,
                      editButtonTitle: editButtonTitle,
                      back: back.asDriver(onErrorJustReturn: ()))
    }
}
