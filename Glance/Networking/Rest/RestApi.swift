//
//  RestApi.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
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
    
    func saveFavorite(id: Any, type: Int) -> Single<Bool> {
        return requestObject(.saveFavorite(id: id, type: type), type: MappableItem<Bool>.self).map { $0.data ?? false }
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

