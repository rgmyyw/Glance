//
//  IbexAPI.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire
import Localize_Swift


protocol ProductAPIType {
    var addXAuth: Bool { get }
}

private let assetDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

enum GlanceAPI {
    case download(url: URL, fileName: String?)
    case getHome(page : Int)

}

extension GlanceAPI: TargetType, ProductAPIType {
    
    var baseURL: URL {
        switch self {
        case .download(let url, _):
            return url
        default:
            return Configs.Network.url.url!
        }
    }
    
    var path: String {
        switch self {
        case .download: return ""
        case .getHome(let page):
            return "/api/home/\(page)/10"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    
    var headers: [String: String]? {
        
        var header : [String : String] = ["Content-Type":"application/json"]
        
//        if loggedIn.value , let token = AuthManager.shared.token?.basicToken {
//            header["Authorization"] = token
//        }

        header["Authorization"] = "Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0SHpZOWZCWElOQ1d2R2xwMnp6ZkphcU5WNHhYbDc0MU9ranZURUNjb1hJIn0.eyJleHAiOjE1OTY2MjAyMTAsImlhdCI6MTU5NDAyODIxMCwianRpIjoiZDhlMDcyZWItZGY1ZC00Y2I1LTkwOTktYmQxOWY1NzcyNjkzIiwiaXNzIjoiaHR0cHM6Ly9nbGFuY2UtZGV2LWFwaS5iZWxpdmUuc2cvYXV0aC9yZWFsbXMvZ2xhbmNlIiwic3ViIjoiZjY5OWQ1MzgtZjlhYi00MjIyLWEwYzYtMTVhNmQxNmE3NGFkIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiZ2xhbmNlLWFwcCIsInNlc3Npb25fc3RhdGUiOiI2ZDQ4OTdiZi02MjVhLTQyN2QtODgyZC00MDkzNjJlYTA4ZDQiLCJhY3IiOiIxIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIm9mZmxpbmVfYWNjZXNzIiwidW1hX2F1dGhvcml6YXRpb24iXX0sInNjb3BlIjoib3BlbmlkIn0.Ydlu2RO5glSEBNBs92D75CwGl-XA1ugyCd22MXmJpo97-g_bEHf2oh9ndQ4IXYOqCiRR5OI4fMMMccu5DpkDp1mhQ-QvBU3aje9apZBfM0vwut3Vq0dwV9T33ovkiOFrFspTZ-8NOflthcGfBU4ZjJwKH37X9Tof-3xTb3d5Ltq55pNZfu5KRhsJ1otQX4pBRPfBvS4jAeiFcCFp0usDmS6Lk7GxSsM1MvPZm7L5qwEi77Kk8w8rcjCCealQo2QMo6kFJxv8fY4dLqsYl4BSAqfffZE9OUS3NEv3_RpHQ21KvxQ4HMdScDwqwtQjG9fOS98y0pwBUSN3xCFuOVMPNA"
        
        header["platform"] = "iOS"
        header["channel-id"] = "1"
        header["app-version"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        header["app-build"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        header["device-brand"] = "Apple"
        header["deviceNo"] = UIDevice.current.identifierForVendor!.uuidString
        header["os-version"] = UIDevice.current.systemVersion
        header["ios-idfv"] = UIDevice.current.identifierForVendor!.uuidString
        header["lang"] = Localize.currentLanguage()
        
        return header
    }
    
    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        default:
            break
        }
        return params
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var localLocation: URL {
        switch self {
        case .download(_, let fileName):
            if let fileName = fileName {
                return assetDir.appendingPathComponent(fileName)
            }
        default: break
        }
        return assetDir
    }
    
    var downloadDestination: DownloadDestination {
        return { _, _ in return (self.localLocation, .removePreviousFile) }
    }
    
    public var task: Task {
        switch self {
        default:
            switch method {
            default:
                if let parameters = parameters {
                    return .requestParameters(parameters: parameters, encoding: parameterEncoding)
                }
                return .requestPlain
            }
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var addXAuth: Bool {
        switch self {
        default: return true
        }
    }
}

private let dformatter = DateFormatter(withFormat: "yyyyMMddHHmmss", locale: Locale.current.description)
