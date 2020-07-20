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
    case collect(id : Any, type : Int, state : Bool)
    case userDetail(userId : String)
    case modifyProfile(data : [String : Any])
    case uploadImage(type: Int, data : Data)
    case userPost(userId : String, pageNum : Int)
    case userRecommend(userId : String, pageNum : Int)
    case userRelation(type : UserRelationType, userId : String, pageNum : Int)
    case follow(userId : String)
    case undoFollow(userId : String)
    case block(userId : String)
    case undoBlocked(userId : String)
    case insightPost(userId : String, pageNum : Int)
    case insightRecommend(userId : String, pageNum : Int)
    case insightsPostDetail(postId : Int)
    case insightsRecommendDetail(recommendId : Int)
    case reactions(recommendId : Int,pageNum : Int)
    case notifications(page : Int)
    case shoppingCart(pageNum : Int)
    case postDetail(postId : Int)
    case shoppingCartDelete(productId : String)
    case like(id : Any, type : Int, state : Bool)
    case savedCllectionClassify
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
            return "/api/home/v2/\(page)/\(10)"
        case .collect:
            return "/api/saved"
        case .userDetail:
            return "/api/users/detail"
        case .modifyProfile:
            return "/api/users/profile"
        case .uploadImage:
            return "/api/image"
        case .userPost(_, let pageNum):
            return "/api/posts/user/\(pageNum)/\(10)"
        case .userRecommend(_, let pageNum):
            return "/api/recommends/user/\(pageNum)/\(10)"
        case .userRelation(let type,_, let pageNum):
            switch type {
            case .following:
                return "/api/follow/following/\(pageNum)/\(10)"
            case .followers:
                return "/api/follow/followers/\(pageNum)/\(10)"
            case .blocked:
                return "/api/blocked/users/\(pageNum)/\(10)"
            }
        case .follow:
            return "/api/follow"
        case .undoFollow:
            return "/api/follow/undo"
        case .block:
            return "/api/blocked/user"
        case .undoBlocked:
            return "/api/blocked/undo"
        case .insightPost(_, let pageNum):
            return "/api/users/insights/posts/\(pageNum)/\(10)"
        case .insightRecommend(_, let pageNum):
            return "/api/users/insights/recommends/\(pageNum)/\(10)"
        case .insightsPostDetail:
            return "/api/users/insights/posts/detail"
        case .insightsRecommendDetail:
            return "/api/users/insights/recommends/detail"
        case .reactions(_, let pageNum):
            return "/api/users/insights/recommended/reactions/users/\(pageNum)/\(10)"
        case .postDetail:
            return "/api/posts/detail"
        case .notifications(let pageNum):
            return "/api/notifications/\(pageNum)/\(10)"
        case .like:
            return "/api/liked"
        case .shoppingCart(let pageNum):
            return "/api/shoppingCart/\(pageNum)/\(10)"
        case .shoppingCartDelete(let productId):
            return "/api/shoppingCart/\(productId)"
        case .savedCllectionClassify:
            return "/api/users/saved/classify"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .collect,.like,.uploadImage,.block,.follow:
            return .post
        case .userDetail,.userPost,
             .userRecommend,
             .userRelation,
             .insightPost,
             .insightRecommend,
             .insightsPostDetail,
             .insightsRecommendDetail,
             .reactions,
             .postDetail,
             .notifications,
             .shoppingCart,
             .savedCllectionClassify:
            return .get
        case .modifyProfile:
            return .put
        case .undoFollow,.undoBlocked,.shoppingCartDelete:
            return .delete
        default:
            return .get
        }
    }
    
    
    var headers: [String: String]? {
        
        var header : [String : String]
        
        switch self {
        case .uploadImage:
            header = ["Content-Type":"application/form-data"]
        default:
            header = ["Content-Type":"application/json"]
        }
        
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
        case .collect(let id, let type, let state):
            params["updateSaved"] = state.int
            params["type"] = type
            switch type {
            case 0,2:
                params["postId"] = id
            case 1,3:
                params["productId"] = id
            default:
                break
            }
        case .like(let id, let type, let state):
            params["updateLiked"] = state.int
            params["type"] = type
            switch type {
            case 0,2:
                params["postId"] = id
            case 1,3:
                params["productId"] = id
            default:
                break
            }
        case .userPost(let userId, _),
             .userRecommend(let userId, _),
             .userRelation(_, let userId, _):
            if userId.isNotEmpty {
                params["otherUserId"] = userId
            }
        case .userDetail(let userId):
            if userId.isNotEmpty {
                params["otherUserId"] = userId
            }
        case .follow(let userId):
            params["followerUserId"] = userId
        case .undoFollow(let userId):
            params["followUserId"] = userId
        case .block(let userId):
            params["blockUserId"] = userId
        case .undoBlocked(let userId):
            params["undoBlockedUserId"] = userId
        case .modifyProfile(let data):
            params.merge(dict: data)
        case .insightRecommend(let userId, _),.insightPost(let userId,_):
            if userId.isNotEmpty {
                params["otherUserId"] = userId
            }
        case .insightsPostDetail(let postId):
            params["postId"] = postId
        case .insightsRecommendDetail(let recommendId):
            params["recommendsId"] = recommendId
        case .reactions(let recommendId, _):
            params["recommendId"] = recommendId
        case .postDetail(let postId):
            params["id"] = postId
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
        case .uploadImage(let type, let data):
            let fileName = dformatter.string(from: Date()) + ".jpeg"
            let formData = MultipartFormData(provider: MultipartFormData.FormDataProvider.data(data), name: "image", fileName: fileName, mimeType: "image/jpeg")
            return .uploadCompositeMultipart([formData], urlParameters: ["type" : type])
        default:
            switch method {
            case .post,.put:
                return .requestData(parameters?.jsonData() ?? Data())
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
