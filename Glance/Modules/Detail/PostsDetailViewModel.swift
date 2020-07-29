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
        let footerRefresh: Observable<Void>
        let selection : Observable<PostsDetailSectionItem>
        let addShoppingCart : Observable<Void>
    }
    
    struct Output {
        let items : Driver<[PostsDetailSection]>
        let userImageURL : Driver<URL?>
        let userName : Driver<String>
        let time : Driver<String>
        let navigationBarType : Driver<Int>
        let productName : Driver<String>
        let bottomBarHidden : Driver<Bool>
        let bottomBarTitle : Driver<String>
        let bottomBarAddButtonHidden : Driver<Bool>
        let bottomBarBackgroundColor : Driver<UIColor?>
        let bottomBarEnable : Driver<Bool>
    }
    
    
    let item : BehaviorRelay<Home>
    
    init(provider: API,item : Home) {
        
        //        var item = item
        //item.postId = 77
        self.item = BehaviorRelay(value: item)
        super.init(provider: provider)
        self.page = 0
        
    }
    
    let similar = BehaviorRelay<PageMapable<PostsDetailProduct>>(value: PageMapable())
    
    func transform(input: Input) -> Output {
        
        let element : BehaviorRelay<PostsDetail> = BehaviorRelay(value: PostsDetail())
        let elements = BehaviorRelay<[PostsDetailSection]>(value: [])
        let userImageURL = element.map { $0.userImage?.url }.asDriver(onErrorJustReturn: nil)
        let userName = element.map { $0.displayName ?? "" }.asDriver(onErrorJustReturn: "")
        let productName = element.map { $0.brand ?? "" }.asDriver(onErrorJustReturn: "")
        let time = element.map { $0.postsTime?.customizedString() ?? "" }.asDriver(onErrorJustReturn: "")
        
        /// 底部添加购物车按钮
        let bottomBarHidden = item.map { !$0.isProduct }.asDriver(onErrorJustReturn: true)
        let bottomBarState = BehaviorRelay<Bool>(value: false)
        let bottomBarTitle = bottomBarState.map { $0 ? "View Shopping List" :  "Add to Shopping List"  }.asDriver(onErrorJustReturn: "")
        let bottomBarAddButtonHidden = bottomBarState.map { $0 }.asDriver(onErrorJustReturn: false)
        let bottomBarBackgroundColor = bottomBarState.map { $0 ? UIColor(hex: 0x8B8B81) : UIColor(hex: 0xFF8159) }.asDriver(onErrorJustReturn: nil)
        let bottomBarEnable = bottomBarState.map { !$0 }.asDriver(onErrorJustReturn: false)
        element.map { $0.inShoppingList }.bind(to: bottomBarState).disposed(by: rx.disposeBag)
        
        /// 添加收藏
        let saveCurrent = PublishSubject<PostsDetailSectionCellViewModel>()
        let saveOther = PublishSubject<PostsDetailCellViewModel>()
        let save = PublishSubject<(AnyObject, [String : Any])>()
        
        let like = PublishSubject<PostsDetailSectionCellViewModel>()
        let recommend = PublishSubject<PostsDetailSectionCellViewModel>()
        
        let navigationBarType = Observable.combineLatest(element.map { $0.own },item.map { $0.type})
            .map { (own, type) -> Int in
                switch type {
                case .product,.recommendProduct:
                    return 0
                case .post,.recommendPost:
                    return own ? 1 : 2
                }
        }.asDriver(onErrorJustReturn: -1)
        
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
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<PostsDetailProduct>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.similar.value.hasNext {
                self.noMoreData.onNext(())
                return Observable.just(RxSwift.Event.next(PageMapable(hasNext: false)))
                    .trackActivity(self.footerLoading)
            }
            self.page += 1
            return self.provider.similarProduct(id: self.item.value.id, type: self.item.value.type.rawValue, page: self.page)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let result):
                var newResult = result
                newResult.list = self.similar.value.list + result.list
                self.similar.accept(newResult)
                if newResult.total <= self.page {
                    self.noMoreData.onNext(())
                }
                
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        saveCurrent.map { cellViewModel -> (AnyObject,[String : Any]) in
            let item = self.item.value
            var params = [String : Any]()
            params["type"] = item.type.rawValue
            params["updateSaved"] = !cellViewModel.saved.value
            switch item.type {
            case .post,.recommendPost:
                params["postId"] = item.postId
            case .product,.recommendProduct:
                params["productId"] = item.productId
            }
            return (cellViewModel,params)
        }.bind(to: save).disposed(by: rx.disposeBag)
        
        
        saveOther.map { cellViewModel -> (AnyObject,[String : Any]) in
            var params = [String : Any]()
            params["type"] = HomeCellType.product.rawValue
            params["updateSaved"] = !cellViewModel.saved.value
            params["productId"] = cellViewModel.item.productId
            return (cellViewModel,params)
        }.bind(to: save).disposed(by: rx.disposeBag)
        
        Observable.combineLatest(element, item, similar).map { (element , item,similar) -> [PostsDetailSection] in
            
            let viewModel = PostsDetailSectionCellViewModel(item: element)
            viewModel.save.map { viewModel}.bind(to: saveCurrent).disposed(by: self.rx.disposeBag)
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
                //sections = [banner,price,title,tags,tool]
                sections = [banner,price,title,tool]
                
            }
            
            let taggedItems = element.taggedProducts.map { item -> PostsDetailSectionItem in
                let cellViewModel = PostsDetailCellViewModel(item: item)
                cellViewModel.save.map { cellViewModel }.bind(to: saveOther).disposed(by: self.rx.disposeBag)
                return PostsDetailSectionItem.tagged(viewModel: cellViewModel)
            }
            let similarItems = similar.list.map { item -> PostsDetailSectionItem in
                let cellViewModel = PostsDetailCellViewModel(item: item)
                cellViewModel.save.map { cellViewModel }.bind(to: saveOther).disposed(by: self.rx.disposeBag)
                return PostsDetailSectionItem.similar(viewModel: cellViewModel)
            }
            let tagged = PostsDetailSection.tagged(viewModel: "Tagged Products", items: taggedItems)
            let similar = PostsDetailSection.similar(viewModel: "Similar Styles", items: similarItems)
            
            
            switch item.type {
            case .post,.recommendPost:
                sections.append(tagged)
                sections.append(similar)
            case .product,.recommendProduct:
                sections.append(similar)
            }
            return sections
            
        }.share().bind(to: elements).disposed(by: rx.disposeBag)
        
        
        save.flatMapLatest({ [weak self] (cellViewModel, param) -> Observable<(RxSwift.Event<(AnyObject,Bool)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.saveCollection(param: param)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: { event in
            switch event {
            case .next(let (cellViewModel, result)):
                if let item = cellViewModel as? PostsDetailSectionCellViewModel {
                    item.saved.accept(result)
                } else if let item = cellViewModel as? PostsDetailCellViewModel {
                    item.saved.accept(result)
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        
        like.map { ($0,element.value,self.item.value) }
            .flatMapLatest({ [weak self] (cellViewModel, element, item) -> Observable<(RxSwift.Event<(PostsDetailSectionCellViewModel,Bool)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                let state = !cellViewModel.liked.value
                return self.provider.like(id: item.id, type: item.type.rawValue, state: state)
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
        
        input.addShoppingCart
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<Bool>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.addShoppingCart(productId: self.item.value.productId ?? "")
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let result):
                    bottomBarState.accept(result)
                    self?.message.onNext(.init("Successfully added to your shopping list"))
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      userImageURL: userImageURL,
                      userName: userName,
                      time : time,
                      navigationBarType: navigationBarType,
                      productName: productName,
                      bottomBarHidden: bottomBarHidden,
                      bottomBarTitle:bottomBarTitle ,
                      bottomBarAddButtonHidden:bottomBarAddButtonHidden,
                      bottomBarBackgroundColor: bottomBarBackgroundColor,
                      bottomBarEnable: bottomBarEnable)
    }
}
