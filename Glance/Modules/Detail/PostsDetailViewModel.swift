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
        let bottomButtonTrigger : Observable<Void>
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
        let shoppingCart : Driver<Void>
        let detail : Driver<Home>
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
        
        let element : BehaviorRelay<PostsDetail?> = BehaviorRelay(value: nil)
        let elements = BehaviorRelay<[PostsDetailSection]>(value: [])
        let userImageURL = element.filterNil().map { $0.userImage?.url }.asDriver(onErrorJustReturn: nil)
        let userName = element.filterNil().map { $0.displayName ?? "" }.asDriver(onErrorJustReturn: "")
        let productName = element.filterNil().map { $0.brand ?? "" }.asDriver(onErrorJustReturn: "")
        let time = element.filterNil().map { $0.postsTime?.customizedString() ?? "" }.asDriver(onErrorJustReturn: "")
        let addShoppingCart = PublishSubject<Void>()
        let shoppingCartList = PublishSubject<Void>()
        let detail = input.selection.map { Home(productId: $0.viewModel.item.productId ?? "") }.asDriver(onErrorJustReturn: Home())
        
        
        /// 底部添加购物车按钮
        let bottomBarHidden = item.map { !($0.type?.isProduct ?? false) }.asDriver(onErrorJustReturn: true)
        let bottomBarButtonState = BehaviorRelay<Bool>(value: false)
        let bottomBarButtonTitle = bottomBarButtonState.map { $0 ? "View Shopping List" :  "Add to Shopping List"  }.asDriver(onErrorJustReturn: "")
        let bottomBarAddButtonHidden = bottomBarButtonState.map { $0 }.asDriver(onErrorJustReturn: false)
        let bottomBarBackgroundColor = bottomBarButtonState.map { $0 ? UIColor(hex: 0x8B8B81) : UIColor(hex: 0xFF8159) }.asDriver(onErrorJustReturn: nil)
        
        
        
        /// 添加收藏
        let saveCurrent = PublishSubject<PostsDetailSectionCellViewModel>()
        let saveOther = PublishSubject<PostsDetailCellViewModel>()
        let save = PublishSubject<(AnyObject, [String : Any])>()
        
        let like = PublishSubject<PostsDetailSectionCellViewModel>()
        let recommend = PublishSubject<PostsDetailSectionCellViewModel>()
        
        //
        element.filterNil().map { $0.inShoppingList }.bind(to: bottomBarButtonState).disposed(by: rx.disposeBag)
        
        let navigationBarType = Observable.combineLatest(element.filterNil().map { $0.own },item.map { $0.type}.filterNil()).map { (own, type) -> Int in
                switch type {
                case .product,.recommendProduct:
                    return 0
                case .post,.recommendPost:
                    return own ? 1 : 2
                }
        }.asDriver(onErrorJustReturn: -1)
        
        item.flatMapLatest({ [weak self] (item) -> Observable<(RxSwift.Event<PostsDetail>)> in
            guard let self = self ,let type = item.type else { return Observable.just(RxSwift.Event.completed) }
            let request = type.isProduct ? self.provider.productDetail(productId: item.productId ?? "") :
                self.provider.postDetail(postId: item.postId)
            return request
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(var item):
                item.type = self?.item.value.type
                element.accept(item)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<PostsDetailProduct>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.similar.value.hasNext {
                return Observable.just(RxSwift.Event.next(PageMapable(hasNext: false)))
                    .trackActivity(self.footerLoading)
            }
            self.page += 1
            return self.provider.similarProduct(params: self.item.value.id, page: self.page)
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
                self.hasData.onNext(result.hasNext)
                
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        saveCurrent.map { cellViewModel -> (AnyObject,[String : Any]) in
            let item = self.item.value
            var params = [String : Any]()
            params["type"] = item.type?.isProduct.int ?? -1
            params["updateSaved"] = !cellViewModel.saved.value
            params.merge(dict: cellViewModel.item.id)
            return (cellViewModel,params)
        }.bind(to: save).disposed(by: rx.disposeBag)
        
        saveOther.map { cellViewModel -> (AnyObject,[String : Any]) in
            var params = [String : Any]()
            params["type"] = HomeCellType.product.rawValue
            params["updateSaved"] = !cellViewModel.saved.value
            params["productId"] = cellViewModel.item.productId
            return (cellViewModel,params)
        }.bind(to: save).disposed(by: rx.disposeBag)
        
        Observable.combineLatest(element.filterNil(), item, similar).map { (element , item ,similar) -> [PostsDetailSection] in
            guard let type = item.type else { return [] }
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
            
            switch type {
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
            switch type {
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
                var params = [String : Any]()
                params["type"] = cellViewModel.item.type?.isProduct.int ?? 0
                params["updateLiked"] = !cellViewModel.liked.value
                params.merge(dict: cellViewModel.item.id)
                return self.provider.like(param: params)
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
        
        addShoppingCart.flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<Bool>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.addShoppingCart(productId: self.item.value.productId ?? "")
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let result):
                bottomBarButtonState.accept(result)
                self?.message.onNext(.init("Successfully added to your shopping list"))
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        input.bottomButtonTrigger.subscribe(onNext: { () in
            let subject = bottomBarButtonState.value ? shoppingCartList : addShoppingCart
            subject.onNext(())
        }).disposed(by: rx.disposeBag)
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      userImageURL: userImageURL,
                      userName: userName,
                      time : time,
                      navigationBarType: navigationBarType,
                      productName: productName,
                      bottomBarHidden: bottomBarHidden,
                      bottomBarTitle:bottomBarButtonTitle ,
                      bottomBarAddButtonHidden:bottomBarAddButtonHidden,
                      bottomBarBackgroundColor: bottomBarBackgroundColor,
                      shoppingCart: shoppingCartList.asDriver(onErrorJustReturn: ()),
                      detail: detail)
    }
}
