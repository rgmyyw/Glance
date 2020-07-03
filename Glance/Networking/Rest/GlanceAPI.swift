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

        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    
    var headers: [String: String]? {
        
        var header : [String : String] = ["Content-Type":"application/json"]
        
        if loggedIn.value , let token = AuthManager.shared.token?.basicToken {
            header["Authorization"] = token
        }
        
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
