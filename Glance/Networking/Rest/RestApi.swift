//
//  RestApi.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper
import Moya
import Moya_ObjectMapper
import Alamofire

typealias MoyaError = Moya.MoyaError

enum ApiError: Error {
    case serverError(response: ErrorResponse)
}


class RestApi: API {
    
    func getHome(page: Int) -> Single<PageMapable<Home>> {
        return requestObject(.getHome(page: page), type: PageMapable<Home>.self)
    }
    
    func userDetail(userId: String = "") -> Single<User> {
        return requestObject(.userDetail(userId: userId), type: User.self)
    }
    
    func modifyProfile(data: [String : Any]) -> Single<User> {
        return requestObject(.modifyProfile(data: data), type: User.self)
    }
    
    func uploadImage(type: Int, size : CGSize, data : Data) -> Single<String> {
        return requestObject(.uploadImage(type: type, size : size, data: data), type: UploadImageResult.self)
            .map { $0.imageUri ?? ""}
    }
    
    func userPost(userId: String, pageNum: Int) -> Single<PageMapable<Home>> {
        return requestObject(.userPost(userId: userId, pageNum: pageNum), type: PageMapable<Home>.self)
    }
    
    func userRecommend(userId: String = "", pageNum: Int) -> Single<PageMapable<Home>> {
        return requestObject(.userRecommend(userId: userId, pageNum: pageNum), type: PageMapable<Home>.self)
    }
    
    func userRelation(type: UserRelationType, userId: String = "", pageNum: Int) -> Single<PageMapable<UserRelation>> {
        return requestObject(.userRelation(type: type, userId: userId, pageNum: pageNum), type: PageMapable<UserRelation>.self)
    }
    
    func follow(userId: String) -> Single<Bool> {
        return requestObject(.follow(userId: userId), type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }
    
    func undoFollow(userId: String) -> Single<Bool> {
        return requestObject(.undoFollow(userId: userId), type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }
    
    func block(userId: String) -> Single<Bool> {
        return requestObject(.block(userId: userId), type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }
    
    func undoBlocked(userId: String) -> Single<Bool> {
        return requestObject(.undoBlocked(userId: userId), type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }
    
    func insightPost(userId: String, pageNum: Int) -> Single<PageMapable<Insight>> {
        return requestObject(.insightPost(userId: userId, pageNum: pageNum), type: PageMapable<Insight>.self)
    }
    
    func insightRecommend(userId: String, pageNum: Int) -> Single<PageMapable<Insight>> {
        return requestObject(.insightRecommend(userId: userId, pageNum: pageNum), type: PageMapable<Insight>.self)
    }
    
    func insightsPostDetail(postId: Int) -> Single<InsightsDetail> {
        return requestObject(.insightsPostDetail(postId: postId), type: InsightsDetail.self)
    }
    
    func insightsrRecommendDetail(recommendId: Int) -> Single<InsightsDetail> {
        return requestObject(.insightsRecommendDetail(recommendId: recommendId), type: InsightsDetail.self)
    }
    
    func reactions(recommendId: Int, pageNum: Int) -> Single<PageMapable<Reaction>> {
        return requestObject(.reactions(recommendId: recommendId, pageNum: pageNum), type: PageMapable<Reaction>.self)
    }
    
    func detail(id: Any, type: Int) -> Single<PostsDetail> {
        return requestObject(.detail(id: id, type : type), type: PostsDetail.self)
        
    }
    
    func like(id: Any, type: Int, state: Bool) -> Single<Bool> {
        return requestObject(.like(id: id, type: type, state: state), type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }
    
    func notifications(pageNum: Int) -> Single<PageMapable<Notification>> {
        return requestObject(.notifications(page: pageNum), type: PageMapable<Notification>.self)
    }
    
    func shoppingCart(pageNum: Int) -> Single<PageMapable<ShoppingCart>> {
        return requestObject(.shoppingCart(pageNum: pageNum), type: PageMapable<ShoppingCart>.self)
        
    }
    
    func shoppingCartDelete(productId: String) -> Single<Bool> {
        return requestObject(.shoppingCartDelete(productId: productId), type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }
    
    func savedCollectionClassify() -> Single<SavedCollection> {
        return requestObject(.savedCllectionClassify, type: SavedCollection.self)
    }
    
    func savedCollection(pageNum: Int) -> Single<PageMapable<Home>> {
        return requestObject(.savedCollection(pageNum: pageNum), type: PageMapable<Home>.self)
    }
    
    /// 收藏 : 返回值，是对这个id 操作最终的结果，取消还是进行收藏
    /// - Parameters:
    ///   - id: id
    ///   - type: 类型 post,product, recommend post, recommend product
    ///   - state: 收藏状态, false 是取消收藏 , true 收藏
    func saveCollection(param: [String : Any]) -> Single<Bool> {
        return requestObject(.saveCollection(param: param), type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }
    
    func interest(level: Int) -> Single<[Interest]> {
        return requestArray(.interest(level: level), type: Interest.self)
    }
    
    func updateUserInterest(ids: String) -> Single<Bool> {
        return requestObject(.updateUserInterest(ids: ids), type: MappableItem<Void>.self,keyPath: nil).map { $0.code == 200}
    }
    
    func similarProduct(id: Any, type: Int, page: Int) -> Single<PageMapable<PostsDetailProduct>> {
        return requestObject(.similarProduct(id: id, type: type, page: page), type: PageMapable<PostsDetailProduct>.self)
    }
    
    func addShoppingCart(productId: String) -> Single<Bool> {
        return requestObject(.addShoppingCart(productId: productId), type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }
    
    func visualSearch(params: [String : Any]) -> Single<VisualSearchPageMapable> {
        return requestObject(.visualSearch(params: params), type: VisualSearchPageMapable.self)
    }
    
    func search(type: SearchType,keywords: String, page: Int) -> Single<PageMapable<Home>> {
        return requestObject(.search(type: type, keywords: keywords, page: page), type: PageMapable<Home>.self)
    }
    
    
    func categories() -> Single<[Categories]> {
        return requestArray(.categories, type: Categories.self)
    }
    
    
    func addProduct(param: [String : Any]) -> Single<String> {
        return requestObject(.addProduct(param: param), type: MappableItem<[String : String]>.self,keyPath: nil).map { $0.data?["productId"] ?? ""}
        
    }
    
    func postProduct(param: [String : Any]) -> Single<Bool> {
        return requestObject(.postProduct(param: param), type: MappableItem<Bool>.self,keyPath: nil).map { $0.code == 200 }
    }
    
    func insightsLiked(postId: Int, pageNum: Int) -> Single<PageMapable<InsightsRelation>> {
        return requestObject(.insightsLiked(postId: postId, pageNum: pageNum), type: PageMapable<InsightsRelation>.self)
    }
    func insightsRecommend(postId : Int, pageNum: Int) -> Single<PageMapable<InsightsRelation>> {
        return requestObject(.insightsRecommend(postId: postId, pageNum: pageNum), type: PageMapable<InsightsRelation>.self)
        
    }
    
    func logout() -> Single<Bool> {
        return requestObject(.logout, type: MappableItem<Bool>.self,keyPath: nil).map { $0.data ?? false}
    }

    func isNewUser() -> Signal<Bool> {
        return requestObject(.isNewUser, type: MappableItem<[String : Bool]>.self,keyPath: nil).map { $0.data?["isNewUser"] ?? false }.asSignal(onErrorJustReturn: false)
    }
    
    
    
    let ibexProvider: IbexNetworking
    
    init(ibexProvider: IbexNetworking) {
        self.ibexProvider = ibexProvider
    }
}



extension RestApi {
    
    func downloadString(url: URL) -> Single<String> {
        return Single.create { single in
            DispatchQueue.global().async {
                do { 
                    single(.success(try String.init(contentsOf: url)))
                } catch {
                    single(.error(error))
                }
            }
            return Disposables.create { }
        }
        .observeOn(MainScheduler.instance)
    }
    
    func downloadFile(url: URL, fileName: String?) -> Single<Void> {
        return ibexProvider.request(.download(url: url, fileName: fileName))
            .mapToVoid()
            .asSingle()
    }
    
    
}

extension RestApi {
    private func request(_ target: GlanceAPI) -> Single<Any> {
        return ibexProvider.request(target)
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    private func requestWithoutMapping(_ target: GlanceAPI) -> Single<Moya.Response> {
        return ibexProvider.request(target)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    private func requestObject<T: BaseMappable>(_ target: GlanceAPI, type: T.Type, keyPath : String? = "data") -> Single<T> {
        
        if let keyPath = keyPath {
            return ibexProvider.request(target)
                .mapObject(T.self,atKeyPath: keyPath)
                .observeOn(MainScheduler.instance)
                .asSingle()
        }
        return ibexProvider.request(target)
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    private func requestArray<T: BaseMappable>(_ target: GlanceAPI, type: T.Type,keyPath : String? = "data") -> Single<[T]> {
        
        if let keyPath = keyPath {
            return ibexProvider.request(target)
                .mapArray(T.self,atKeyPath: keyPath)
                .observeOn(MainScheduler.instance)
                .asSingle()
        }
        
        return ibexProvider.request(target)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
}

