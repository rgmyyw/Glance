//
//  RestApi.swift
//  
//
//  Created by yanghai on 3/9/19.
//  Copyright © 2019 yanghai. All rights reserved.
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

    var title: String {
        switch self {
        case .serverError(let response): return response.message ?? ""
        }
    }

    var description: String {
        switch self {
        case .serverError(let response): return response.detail()
        }
    }
}

class RestApi: API {

    let githubProvider: Networking
    let trendingGithubProvider: TrendingNetworking
    let codetabsProvider: CodetabsNetworking

    init(githubProvider: Networking, trendingGithubProvider: TrendingNetworking, codetabsProvider: CodetabsNetworking) {
        self.githubProvider = githubProvider
        self.trendingGithubProvider = trendingGithubProvider
        self.codetabsProvider = codetabsProvider
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
        return githubProvider.request(.download(url: url, fileName: fileName))
            .mapToVoid()
            .asSingle()
    }

    // MARK: - Authentication is optional

    func createAccessToken(clientId: String, clientSecret: String, code: String, redirectUri: String?, state: String?) -> Single<Token> {
        return Single.create { single in
            var params: Parameters = [:]
            params["client_id"] = clientId
            params["client_secret"] = clientSecret
            params["code"] = code
            params["redirect_uri"] = redirectUri
            params["state"] = state
            AF.request("https://github.com/login/oauth/access_token",
                       method: .post,
                       parameters: params,
                       encoding: URLEncoding.default,
                       headers: ["Accept": "application/json"])
                .responseJSON(completionHandler: { (response) in
                    if let error = response.error {
                        single(.error(error))
                        return
                    }
                    if let json = response.value as? [String: Any] {
                        if let token = Mapper<Token>().map(JSON: json) {
                            single(.success(token))
                            return
                        }
                    }
                    single(.error(RxError.unknown))
                })
            return Disposables.create { }
            }
            .observeOn(MainScheduler.instance)
    }

}

extension RestApi {
    private func request(_ target: API) -> Single<Any> {
        return githubProvider.request(target)
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .asSingle()
    }

    private func requestWithoutMapping(_ target: API) -> Single<Moya.Response> {
        return githubProvider.request(target)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }

    private func requestObject<T: BaseMappable>(_ target: API, type: T.Type) -> Single<T> {
        return githubProvider.request(target)
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }

    private func requestArray<T: BaseMappable>(_ target: API, type: T.Type) -> Single<[T]> {
        return githubProvider.request(target)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
}

extension RestApi {
    private func trendingRequestObject<T: BaseMappable>(_ target: TrendingGithubAPI, type: T.Type) -> Single<T> {
        return trendingGithubProvider.request(target)
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }

    private func trendingRequestArray<T: BaseMappable>(_ target: TrendingAPI, type: T.Type) -> Single<[T]> {
        return trendingGithubProvider.request(target)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
}

extension RestApi {
    private func codetabsRequestArray<T: BaseMappable>(_ target: CodetabsApi, type: T.Type) -> Single<[T]> {
        return codetabsProvider.request(target)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
}
