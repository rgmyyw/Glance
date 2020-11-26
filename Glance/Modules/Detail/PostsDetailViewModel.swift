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

struct PostsDetailMemuItem {
    var type: PostsDetailMemuType
    var title: String {
        return type.title
    }
}

enum PostsDetailMemuType {
    case edit
    case delete

    var title: String {
        switch self {
        case .delete:
            return "Delete"
        case .edit:
            return "Edit"
        }
    }
}

class PostsDetailViewModel: ViewModel, ViewModelType {

    struct Input {
        let footerRefresh: Observable<Void>
        let selection: Observable<DefaultColltionSectionItem>
        let bottomButtonTrigger: Observable<Void>
        let memu: Observable<Void>
        let memuSelection: Observable<Int>
    }

    struct Output {
        let items: Driver<[PostsDetailSection]>
        let userImageURL: Driver<URL?>
        let userName: Driver<String>
        let time: Driver<String>
        let navigationBarType: Driver<Int>
        let productName: Driver<String>
        let bottomBarHidden: Driver<Bool>
        let bottomBarTitle: Driver<String>
        let bottomBarAddButtonHidden: Driver<Bool>
        let bottomBarBackgroundColor: Driver<UIColor?>
        let shoppingCart: Driver<Void>
        let detail: Driver<DefaultColltionItem>
        let popMemu: Driver<[PostsDetailMemuItem]>
        let delete: Driver<Void>
        let back: Driver<Void>
        let selectStore: Driver<String>
        let openURL: Driver<URL>
        let viSearch: Driver<UIImage>
        let reloadSection: Driver<Int>
    }

    let item: BehaviorRelay<DefaultColltionItem>
    let memuSelection = PublishSubject<PostsDetailMemuItem>()
    let deletePost = PublishSubject<Void>()
    let selectStoreActions = PublishSubject<(action: SelectStoreAction, item: SelectStore)>()
    let similar = BehaviorRelay<PageMapable<DefaultColltionItem>?>(value: nil)

    init(provider: API, item: DefaultColltionItem) {
        self.item = BehaviorRelay(value: item)
        super.init(provider: provider)
        self.page = 0

    }

    func transform(input: Input) -> Output {

        let element: BehaviorRelay<PostsDetail?> = BehaviorRelay(value: nil)
        let elements = BehaviorRelay<[PostsDetailSection]>(value: [])
        let openURL = PublishSubject<URL>()
        let detail = PublishSubject<DefaultColltionItem>()
        let addShoppingCart = PublishSubject<Void>()
        let shoppingCartList = PublishSubject<Void>()
        let viSearch = PublishSubject<UIImage?>()
        let reloadTitleSection = PublishSubject<PostsDetailSectionCellViewModel>()
        let reloadSection = PublishSubject<Int>()
        let bottomBarButtonState = BehaviorRelay<Bool>(value: false)
        let selectStore = PublishSubject<PostsDetailSectionCellViewModel>()
        let saveCurrent = PublishSubject<PostsDetailSectionCellViewModel>()
        let saveOther = PublishSubject<DefaultColltionCellViewModel>()
        let back = PublishSubject<Void>()
        let save = PublishSubject<(AnyObject, [String: Any])>()
        let like = PublishSubject<PostsDetailSectionCellViewModel>()
        let recommend = PublishSubject<PostsDetailSectionCellViewModel>()

        let userImageURL = element.filterNil().map { $0.userImage?.url }
        let userName = element.filterNil().map { $0.displayName ?? "" }
        let productName = element.filterNil().map { $0.brand ?? "" }
        let time = element.filterNil().map { $0.postsTime?.customizedString() ?? "" }

        let delete = input.memuSelection.filter { $0 == 1 }.mapToVoid()
        let isProduct = item.map { !($0.type?.isProduct ?? false) }
        let bottomBarHidden = Observable.combineLatest(elements.filterEmpty(), isProduct).map { $1 }
        let bottomBarAddButtonHidden = bottomBarButtonState.map { $0 }

        let bottomBarButtonTitle = bottomBarButtonState
            .map { (state) -> String in
                return state ? "View Shopping List" :
                "Add to Shopping List"
        }

        let bottomBarBackgroundColor = bottomBarButtonState
            .map { (state) -> UIColor? in
                return state ? UIColor(hex: 0x8B8B81) :
                    UIColor(hex: 0xFF8159)
        }

        let popMemu = input.memu.map { () -> [PostsDetailMemuItem]  in
            return [PostsDetailMemuItem(type: .edit),
                    PostsDetailMemuItem(type: .delete)]
        }

        let navigationBarType = Observable.combineLatest(
            element.filterNil().map { $0.own }, item
                .map { $0.type}.filterNil())
            .map { (own, type) -> Int in
                switch type {
                case .product, .recommendProduct:
                    return 0
                case .post, .recommendPost:
                    return own ? 1 : 2
                default:
                    fatalError()
                }
        }

        input.selection.map { (element) -> DefaultColltionItem in
            DefaultColltionItem(productId: element.viewModel.item.productId ?? "")
        }.bind(to: detail)
            .disposed(by: rx.disposeBag)

        element.filterNil().map { (element) -> Bool in
            element.inShoppingList
        }.bind(to: bottomBarButtonState)
            .disposed(by: rx.disposeBag)

        selectStoreActions.filter { $0.action == .buy }
            .map { (viewModel) -> URL? in
                viewModel.item.productUrl?.url
        }.filterNil()
            .bind(to: openURL).disposed(by: rx.disposeBag)

        selectStoreActions.filter { $0.action == .jump }
            .map { (viewModel) -> DefaultColltionItem  in
                DefaultColltionItem(productId: viewModel.item.productId ?? "")
        }.delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: detail).disposed(by: rx.disposeBag)

        selectStoreActions.filter { $0.action == .add }
            .filter { $0.item.productId == self.item.value.productId }
            .map { _ in true
        }.bind(to: bottomBarButtonState).disposed(by: rx.disposeBag)

        reloadTitleSection.map { (cellViewModel) -> Int? in
            elements.value.firstIndex { $0 == PostsDetailSection.title(viewModel: cellViewModel)}
        }.filterNil()
            .bind(to: reloadSection).disposed(by: rx.disposeBag)

        input.bottomButtonTrigger.map { () -> PublishSubject<Void> in
            bottomBarButtonState.value ? shoppingCartList : addShoppingCart
        }.subscribe(onNext: { (ob) in
            ob.onNext(())
        }).disposed(by: rx.disposeBag)

        input.memuSelection.filter { $0 == 0 }
            .map { index -> Message  in
                Message("Features under development...")
        }.bind(to: message)
            .disposed(by: rx.disposeBag)

        item.flatMapLatest({ [weak self] (item) -> Observable<(RxSwift.Event<PostsDetail>)> in
            guard let self = self else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            guard let type = item.type else {
                return Observable.just(.error(ExceptionError.general("type is empty")))
            }
            let request = type.isProduct ? self.provider.productDetail(productId: item.productId ?? "") :
                self.provider.postDetail(postId: item.postId)
            return request
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next(var item):
                item.type = self.item.value.type
                element.accept(item)
            case .error(let error):
                guard let error = error.asExceptionError else { return }
                switch error {
                default:
                    self.refreshState.onNext(.end)
                    logError(error.debugDescription)
                }

            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        input.footerRefresh
            .flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<DefaultColltionItem>>> in
                guard let self = self else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                self.page += 1
                let id = self.item.value.id
                let request = self.provider.similarProduct(params: id, page: self.page)
                return self.page == 1 ? request
                    .trackActivity(self.loading)
                    .trackError(self.error)
                    .materialize() : request
                        .trackActivity(self.footerLoading)
                        .trackError(self.error)
                        .materialize()
            }).subscribe(onNext: { [weak self](event) in
                guard let self = self else { return }
                switch event {
                case .next(let result):
                    var newResult = result
                    newResult.list = (self.similar.value?.list ?? []) + result.list
                    self.similar.accept(newResult)
                    self.refreshState.onNext(result.refreshState)
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error {
                    default:
                        self.page -= 1
                        self.refreshState.onNext(.end)
                        logError(error.debugDescription)
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        saveCurrent.map { cellViewModel -> (AnyObject, [String: Any]) in
            let item = self.item.value
            var params = [String: Any]()
            params["type"] = item.type?.isProduct.int ?? -1
            params["updateSaved"] = !cellViewModel.saved.value
            params.merge(dict: cellViewModel.item.id)
            return (cellViewModel, params)
        }.bind(to: save).disposed(by: rx.disposeBag)

        saveOther.map { cellViewModel -> (AnyObject, [String: Any]) in
            var params = [String: Any]()
            params["type"] = DefaultColltionCellType.product.rawValue
            params["updateSaved"] = !cellViewModel.saved.value
            params["productId"] = cellViewModel.item.productId
            return (cellViewModel, params)
        }.bind(to: save).disposed(by: rx.disposeBag)

        Observable.combineLatest(element.filterNil(), item, similar.filterNil()).map { (element, item, similar) -> [PostsDetailSection] in
            guard let type = item.type else { return [] }

            let viewModel = PostsDetailSectionCellViewModel(item: element)
            viewModel.save.map { viewModel}.bind(to: saveCurrent).disposed(by: self.rx.disposeBag)
            viewModel.like.map { viewModel}.bind(to: like).disposed(by: self.rx.disposeBag)
            viewModel.recommend.map { viewModel}.bind(to: recommend).disposed(by: self.rx.disposeBag)
            viewModel.selectStore.map { viewModel}.bind(to: selectStore).disposed(by: self.rx.disposeBag)
            viewModel.viSearch.bind(to: viSearch).disposed(by: self.rx.disposeBag)
            viewModel.reloadTitleSection.map { viewModel }.bind(to: reloadTitleSection).disposed(by: self.rx.disposeBag)
            viewModel.folded.mapToVoid().bind(to: viewModel.reloadTitleSection).disposed(by: self.rx.disposeBag)

            var sections: [PostsDetailSection]
            let banner = PostsDetailSection.banner(viewModel: viewModel)
            let price = PostsDetailSection.price(viewModel: viewModel)
            let title = PostsDetailSection.title(viewModel: viewModel)
            let more = PostsDetailSection.more(viewModel: viewModel)

            //let tags = PostsDetailSection.tags(viewModel: viewModel)
            let tool = PostsDetailSection.tool(viewModel: viewModel)
            let line = viewModel.titleLine
            switch type {
            case .post, .recommendPost:
                sections = line > 3 ? [banner, title, more, tool] : [banner, title, tool]
            case .product, .recommendProduct:
                //sections = [banner,price,title,tags,tool]
                sections = line > 3 ? [banner, price, title, more, tool] : [banner, price, title, tool]
            default:
                fatalError()
            }

            let taggedItems = element.taggedProducts.map { item -> DefaultColltionSectionItem  in
                let viewModel = DefaultColltionCellViewModel(item: item)
                viewModel.col = 3
                viewModel.save.map { _ in  viewModel }.bind(to: saveOther).disposed(by: self.rx.disposeBag)
                viewModel.recommendButtonHidden.accept(true)
                return viewModel.makeItemType()
            }

            let similarItems = similar.list.map { item -> DefaultColltionSectionItem  in
                let viewModel = DefaultColltionCellViewModel(item: item)
                viewModel.save.map { _ in  viewModel }.bind(to: saveOther).disposed(by: self.rx.disposeBag)
                viewModel.recommendButtonHidden.accept(true)
                return viewModel.makeItemType()
            }

            let tagged = PostsDetailSection.tagged(title: "Tagged Products", items: taggedItems)
            let similar = PostsDetailSection.similar(title: "Similar Styles", items: similarItems)
            switch type {
            case .post, .recommendPost:
                sections.append(tagged)
                sections.append(similar)
            case .product, .recommendProduct:
                sections.append(similar)
            default:
                fatalError()
            }
            return sections

        }.share().bind(to: elements).disposed(by: rx.disposeBag)

        save.flatMapLatest({ [weak self] (cellViewModel, param) -> Observable<(RxSwift.Event<(AnyObject, Bool)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.saveCollection(param: param)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: { [weak self]event in
            switch event {
            case .next(let (cellViewModel, result)):
                if let item = cellViewModel as? PostsDetailSectionCellViewModel {
                    item.saved.accept(result)
                    if var item = self?.item.value {
                        item.saved = result
                        kUpdateItem.onNext((.saved, item, self))
                    }
                } else if let item = cellViewModel as? DefaultColltionCellViewModel {
                    item.saved.accept(result)
                    if var item = self?.item.value {
                        item.saved = result
                        kUpdateItem.onNext((.saved, item, self))
                    }
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        like.map { ($0, element.value, self.item.value) }
            .flatMapLatest({ [weak self] (cellViewModel, element, item) -> Observable<(RxSwift.Event<(PostsDetailSectionCellViewModel, Bool)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                var params = [String: Any]()
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

        Observable.combineLatest(deletePost, element.compactMap { $0?.postId})
            .flatMapLatest({ [weak self] (_, id) -> Observable<(RxSwift.Event<(Bool, Int)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.deletePost(postId: id)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .map { ( $0, id)}
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let (result, id)):
                    self?.message.onNext(.init("Your post has been removed"))
                    back.onNext(())
                    if result {
                        let item = DefaultColltionItem(postId: id)
                        kUpdateItem.onNext((.delete, item, self))
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        recommend.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(PostsDetailSectionCellViewModel, Bool)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            var params = [String: Any]()
            params["recommend"] = !cellViewModel.recommended.value
            params.merge(dict: cellViewModel.item.id)
            return self.provider.recommend(param: params)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let (item, result)):
                item.recommended.accept(result)
                if var element = self?.item.value {
                    element.recommended = result
                    kUpdateItem.onNext((.recommend, element, self))
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        kUpdateItem.subscribe(onNext: { [weak self](state, item, trigger) in
            guard trigger != self else { return }
            let items = elements.value.flatMap { $0.items.compactMap { $0.viewModel }}.filter { $0.item == item}
            switch state {
            case .delete:
                guard var t = self?.similar.value else { return }
                var list = t.list
                if let index = list.firstIndex(where: { $0 == item}) {
                    list.remove(at: index)
                    t.list = list
                    self?.similar.accept(t)
                }
            case .like:
                break
            case .saved:
                items.forEach { $0.saved.accept(item.saved)}
            case .recommend:
                items.forEach { $0.saved.accept(item.recommended)}
            }

        }).disposed(by: rx.disposeBag)

        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      userImageURL: userImageURL.asDriverOnErrorJustComplete(),
                      userName: userName.asDriverOnErrorJustComplete(),
                      time: time.asDriverOnErrorJustComplete(),
                      navigationBarType: navigationBarType.asDriverOnErrorJustComplete(),
                      productName: productName.asDriverOnErrorJustComplete(),
                      bottomBarHidden: bottomBarHidden.asDriverOnErrorJustComplete(),
                      bottomBarTitle: bottomBarButtonTitle.asDriverOnErrorJustComplete() ,
                      bottomBarAddButtonHidden: bottomBarAddButtonHidden.asDriverOnErrorJustComplete(),
                      bottomBarBackgroundColor: bottomBarBackgroundColor.asDriverOnErrorJustComplete(),
                      shoppingCart: shoppingCartList.asDriver(onErrorJustReturn: ()),
                      detail: detail.asDriver(onErrorJustReturn: DefaultColltionItem()),
                      popMemu: popMemu.asDriver(onErrorJustReturn: []),
                      delete: delete.asDriver(onErrorJustReturn: ()),
                      back: back.asDriver(onErrorJustReturn: ()),
                      selectStore: selectStore.map { $0.item.productId}.filterNil().asDriver(onErrorJustReturn: ""),
                      openURL: openURL.asDriverOnErrorJustComplete(),
                      viSearch: viSearch.filterNil().asDriverOnErrorJustComplete(),
                      reloadSection: reloadSection.asDriverOnErrorJustComplete())
    }
}
