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
    
    
    let item : BehaviorRelay<Home>
    
    init(provider: API,item : Home) {
        var item = item
        item.postId = 77
        self.item = BehaviorRelay(value: item)
        super.init(provider: provider)
        
    }
    
    func transform(input: Input) -> Output {
        
        let element : BehaviorRelay<PostsDetail> = BehaviorRelay(value: PostsDetail())
        let elements = BehaviorRelay<[PostsDetailSection]>(value: [])
        let userImageURL = element.map { $0.userImage?.url }.asDriver(onErrorJustReturn: nil)
        let userName = element.map { $0.displayName ?? "" }.asDriver(onErrorJustReturn: "")
        let time = element.map { $0.postsTime?.customizedString() ?? "" }.asDriver(onErrorJustReturn: "")
        
        let savePost = PublishSubject<PostsDetailSectionCellViewModel>()
        let saveProduct = PublishSubject<PostsDetailCellViewModel>()
        let like = PublishSubject<PostsDetailSectionCellViewModel>()
        let recommend = PublishSubject<PostsDetailSectionCellViewModel>()
            
        item.flatMapLatest({ [weak self] (item) -> Observable<(RxSwift.Event<PostsDetail>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.detail(id: item.id, type: item.type.rawValue)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let item):
                    element.accept(item)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
                
        Observable.combineLatest(element, item).map { (element , item) -> [PostsDetailSection] in
            
            let viewModel = PostsDetailSectionCellViewModel(item: element)
            viewModel.save.map { viewModel}.bind(to: savePost).disposed(by: self.rx.disposeBag)
            viewModel.like.map { viewModel}.bind(to: like).disposed(by: self.rx.disposeBag)
            viewModel.recommend.map { viewModel}.bind(to: recommend).disposed(by: self.rx.disposeBag)
            
            
            var sections : [PostsDetailSection]
            let banner = PostsDetailSection.banner(viewModel: viewModel)
            let price = PostsDetailSection.price(viewModel: viewModel)
            let title = PostsDetailSection.title(viewModel: viewModel)
            let tags = PostsDetailSection.tags(viewModel: viewModel)
            let tool = PostsDetailSection.tool(viewModel: viewModel)
            
            switch item.type {
            case .post,.recommendPost:
                sections = [banner,title,tool]
            case .product,.recommendProduct:
                sections = [banner,price,title,tags,tool]
            }

            let taggedItems = element.taggedProducts.map { item -> PostsDetailSectionItem in
                let cellViewModel = PostsDetailCellViewModel(item: item)
                return PostsDetailSectionItem.tagged(viewModel: cellViewModel)
            }
            let similarItems = element.similarProducts.map { item -> PostsDetailSectionItem in
                let cellViewModel = PostsDetailCellViewModel(item: item)
                cellViewModel.save.map { cellViewModel }.bind(to: saveProduct).disposed(by: self.rx.disposeBag)
                return PostsDetailSectionItem.similar(viewModel: cellViewModel)
            }
            
            let tagged = PostsDetailSection.tagged(viewModel: "Tagged Products", items: taggedItems)
            let similar = PostsDetailSection.similar(viewModel: "Similar Styles", items: similarItems)
            
            
            sections.append(tagged)
            sections.append(similar)
            
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        
        savePost.map { ($0,element.value,self.item.value) }
            .flatMapLatest({ [weak self] (cellViewModel, element, item) -> Observable<(RxSwift.Event<(PostsDetailSectionCellViewModel,Bool)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                let state = !cellViewModel.saved.value
                return self.provider.saveCollection(id: item.id, type: item.type.rawValue, state: state)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .map { (cellViewModel, $0)}
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let (cellViewModel, result)):
                    if result {
                        cellViewModel.saved.accept(result)
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        saveProduct
            .flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(PostsDetailCellViewModel,Bool)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                let state = !cellViewModel.saved.value
                return self.provider.saveCollection(id: cellViewModel.item.imName ?? "", type: HomeCellType.product.rawValue, state: state)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .map { (cellViewModel, $0)}
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let (cellViewModel, result)):
                    cellViewModel.saved.accept(result)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        

        like.map { ($0,element.value,self.item.value) }
            .flatMapLatest({ [weak self] (cellViewModel, element, item) -> Observable<(RxSwift.Event<(PostsDetailSectionCellViewModel,Bool)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                let state = !cellViewModel.liked.value
                return self.provider.like(id: item.postId, type: HomeCellType.post.rawValue, state: state)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .map { (cellViewModel, $0)}
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let (cellViewModel, result)):
                    cellViewModel.liked.accept(result)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        return Output(items: elements.asDriver(onErrorJustReturn: []), userImageURL: userImageURL,userName: userName,time : time)
    }
}
