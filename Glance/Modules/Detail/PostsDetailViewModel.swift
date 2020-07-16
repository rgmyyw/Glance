//
//  PostsDetailViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift



class PostsDetailViewModel: ViewModel, ViewModelType {
    
    struct Input {
        //        let footerRefresh: Observable<Void>
        let selection : Observable<PostsDetailSectionItem>
    }
    
    struct Output {
        let items : Driver<[PostsDetailSection]>
        let userImageURL : Driver<URL?>
        let userName : Driver<String>
        let time : Driver<String>
    }
    
    
    let item : BehaviorRelay<Recommend>
    
    init(provider: API,item : Recommend) {
        self.item = BehaviorRelay(value: item)
        super.init(provider: provider)
    }
    
    
    
    func transform(input: Input) -> Output {
        
        let element : BehaviorRelay<PostsDetail> = BehaviorRelay(value: PostsDetail())
        let elements = BehaviorRelay<[PostsDetailSection]>(value: [])
        let userImageURL = element.map { $0.userImage?.url }.asDriver(onErrorJustReturn: nil)
        let userName = element.map { $0.displayName ?? "" }.asDriver(onErrorJustReturn: "")
        let time = element.map { _ in "1231231" }.asDriver(onErrorJustReturn: "")
        
        let save = PublishSubject<Void>()
        let like = PublishSubject<Void>()
        let recommend = PublishSubject<Void>()
        
        
        Observable.just(())
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PostsDetail>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                return self.provider.postDetail(postId: 77)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    element.accept(item)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        element.map { element -> [PostsDetailSection] in
            let viewModel = PostsDetailSectionCellViewModel(item: element)
            viewModel.save.bind(to: save).disposed(by: self.rx.disposeBag)
            viewModel.like.bind(to: like).disposed(by: self.rx.disposeBag)
            viewModel.recommend.bind(to: recommend).disposed(by: self.rx.disposeBag)
            //            viewModel.height
            //                .subscribe(onNext: { (height) in
            //                    elements.accept(elements.value)
            //            }).disposed(by: self.rx.disposeBag)
            
            let head = PostsDetailSection.head(viewModel: viewModel)
            let taggedItems = element.taggedProducts.map { item -> PostsDetailSectionItem in
                let cellViewModel = PostsDetailCellViewModel(item: item)
                return PostsDetailSectionItem.tagged(viewModel: cellViewModel)
            }
            let similarItems = element.similarProducts.map { item -> PostsDetailSectionItem in
                let cellViewModel = PostsDetailCellViewModel(item: item)
                return PostsDetailSectionItem.similar(viewModel: cellViewModel)
            }
            
            let tagged = PostsDetailSection.tagged(viewModel: "Tagged Products", items: taggedItems)
            let similar = PostsDetailSection.similar(viewModel: "Similar Styles", items: similarItems)
            return [head,tagged,similar]
        }.bind(to: elements).disposed(by: rx.disposeBag)
       
        
//        save.map { (self.item.value,element.value) }
//            .flatMapLatest({ [weak self] (item, element) -> Observable<(RxSwift.Event<Bool>)> in
//                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
//                return self.provider.collect(id: item.postId, type: item.type?.rawValue ?? 0, state: element.saved)
//                    .trackError(self.error)
//                    .trackActivity(self.loading)
//                    .materialize()
//            }).subscribe(onNext: { [weak self] event in
//                guard let self = self else { return }
//                switch event {
//                case .next(let item):
//                    element.accept(item)
//                default:
//                    break
//                }
//            }).disposed(by: rx.disposeBag)
        
        
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []), userImageURL: userImageURL,userName: userName,time : time)
    }
}
