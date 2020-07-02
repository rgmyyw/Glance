//
//  GitHubAPI.swift
//  
//
//  Created by yanghai on 1/4/17.
//  Copyright © 2017 yanghai. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire

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
            return Configs.Network.githubBaseUrl.url!
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
        if let token = AuthManager.shared.token {
            switch token.type() {
            case .basic(let token):
                return ["Authorization": "Basic \(token)"]
            case .personal(let token):
                return ["Authorization": "token \(token)"]
            case .oAuth(let token):
                return ["Authorization": "token \(token)"]
            case .unauthorized: break
            }
        }
        return nil
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        default: break
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
        case .download:
            return .downloadDestination(downloadDestination)
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }

    var sampleData: Data {
        var dataUrl: URL?
        switch self {
        case .download: break
        }
        if let url = dataUrl, let data = try? Data(contentsOf: url) {
            return data
        }
        return Data()
    }

    var addXAuth: Bool {
        switch self {
        default: return true
        }
    }
}
