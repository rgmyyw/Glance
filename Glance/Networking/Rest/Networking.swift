//
//  Networking.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire
import Toast_Swift
import ObjectMapper


class OnlineProvider<Target> where Target: Moya.TargetType {
    fileprivate let online: Observable<Bool>
    fileprivate let provider: MoyaProvider<Target>

    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider<Target>.neverStub,
         session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false,
         online: Observable<Bool> = connectedToInternet()) {
        self.online = online
        self.provider = MoyaProvider(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, session: session, plugins: plugins, trackInflights: trackInflights)
    }

    func request(_ token: Target) -> Observable<Moya.Response> {
        let actualRequest = provider.rx.request(token)
        return online
            .ignore(value: false)
            .take(1)
            .flatMap { (_) in
                return actualRequest.filterSuccessfulStatusCodes()
                    .asObservable()
                    .do(onNext: { (response) in
                        do {
                            let object = try response.mapObject(MappableItem<Void>.self)
                            if object.code == 200 {
                            } else {
                                throw MoyaError.jsonMapping(response)
                            }
                        }
                        
                    }, onError: { (error) in
                        if let error = error as? MoyaError {
                            switch error {
                            case .statusCode(let response):
                                print("response.statusCode == 401")
//                                if response.statusCode == 401 {
//                                    AuthManager.removeToken()
//                                    User.removeCurrentUser()
//                                }
                            default:
                                UIApplication.shared.keyWindow?.topMostController()?.view.makeToast("server error")
                            }
                        }
                    })
        }
    }
}

protocol NetworkingType {
    associatedtype T: TargetType, ProductAPIType
    var provider: OnlineProvider<T> { get }
}

struct IbexNetworking: NetworkingType {
    typealias T = GlanceAPI
    let provider: OnlineProvider<GlanceAPI>
}

// MARK: - "Public" interfaces
extension IbexNetworking {
    func request(_ token: GlanceAPI) -> Observable<Moya.Response> {
        let actualRequest = self.provider.request(token)
        return actualRequest
    }
}

// Static methods
extension NetworkingType {
    static func ibexNetworking() -> IbexNetworking {
        return IbexNetworking(provider: newProvider(plugins))
    }
}



extension NetworkingType {
    static func endpointsClosure<T>(_ xAccessToken: String? = nil) -> (T) -> Endpoint where T: TargetType, T: ProductAPIType {
        return { target in
            let endpoint = MoyaProvider.defaultEndpointMapping(for: target)

            // Sign all non-XApp, non-XAuth token requests
            return endpoint
        }
    }

    static func APIKeysBasedStubBehaviour<T>(_: T) -> Moya.StubBehavior {
        return .never
    }

    static var plugins: [PluginType] {
        let plugins: [PluginType] = [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter),
        logOptions: .verbose)), newworkActivityPlugin]
        return plugins
    }

    // (Endpoint<Target>, NSURLRequest -> Void) -> Void
    static func endpointResolver() -> MoyaProvider<T>.RequestClosure {
        return { (endpoint, closure) in
            do {
                var request = try endpoint.urlRequest() // endpoint.urlRequest
                request.httpShouldHandleCookies = false
                closure(.success(request))
            } catch {
                logError(error.localizedDescription)
            }
        }
    }
}

private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

private let newworkActivityPlugin = NetworkActivityPlugin { (changeType , targetType) -> () in
    
    switch(changeType){
    case .ended:
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    case .began:
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
}


//struct JSONHandlePlugin: PluginType {
//
//    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
//        switch result {
//        case .success(let response):
//            do {
//                let object = try response.mapObject(BaseMappableModel.self)
//                if object.code == 200 , let data = object.data {
//                    let data = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//                    return Result<Response, MoyaError>.success(Response(statusCode: 200, data: data))
//                } else {
//                    return Result<Response, MoyaError>.failure(.statusCode(response))
//                }
//            } catch  {
//                return Result<Response, MoyaError>.failure(.jsonMapping(response))
//            }
//        default:
//            return result
//        }
//    }
//}

struct AuthPlugin: PluginType {
    
    let token: String
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.timeoutInterval = 30
        return request
    }
}

private func newProvider<T>(_ plugins: [PluginType], xAccessToken: String? = nil) -> OnlineProvider<T> where T: ProductAPIType {
    return OnlineProvider(endpointClosure: IbexNetworking.endpointsClosure(xAccessToken),
                          requestClosure: IbexNetworking.endpointResolver(),
                          stubClosure: IbexNetworking.APIKeysBasedStubBehaviour,
                          plugins: plugins)
}

// MARK: - Provider support

private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
