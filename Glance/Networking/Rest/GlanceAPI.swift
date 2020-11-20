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
    case userDetail(userId : String?)
    case modifyProfile(data : [String : Any])
    case uploadImage(type: Int, size : CGSize, data : Data)
    case userPost(userId : String, pageNum : Int)
    case userRecommend(userId : String, pageNum : Int)
    case users(type : UsersType, userId : String, pageNum : Int)
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
    case productDetail(productId : String)
    case shoppingCartDelete(productId : String)
    case like(param : [String : Any])
    case saveCollection(param : [String : Any])
    case savedCllectionClassify
    case savedCollection(pageNum : Int)
    case interest(level : Int)
    case updateUserInterest(ids : String)
    case similarProduct(params : [String : Any],page : Int)
    case addShoppingCart(productId : String)
    case visualSearch(params : [String : Any])
    case search(type : ProductSearchType,keywords : String, page : Int)
    case categories
    case addProduct(param : [String : Any])
    case postProduct(param : [String : Any])
    case insightsLiked(postId: Int,pageNum : Int)
    case insightsRecommend(postId: Int,pageNum : Int)
    case logout
    case isNewUser
    case reactionAnalysis(recommendId : Int)
    case deletePost(postId : Int)
    case recommend(param : [String : Any])
    case reaction(recommendId : Int,type : Int)
    case searchFacets(query : String)
    case searchThemeClassify
    case searchThemeHot(classifyId : Int, page : Int)
    case searchYouMaylike(page : Int)
    case searchNew(page : Int)
    case globalSearch(type : SearchResultContentType,keywords : String, page : Int)
    case searchThemeDetail(themeId : Int)
    case searchThemeDetaiResource(type : SearchThemeContentType,themeId : Int, page : Int)
    case searchThemeLabelDetaiResource(type : SearchThemeLabelContentType,labelId : Int, page : Int)
    case compareOffers(productId : String)
    case deleteNotice(noticeId : Int)
    case makeRead(values : [String : Any])
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
        case .saveCollection:
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
        case .users(let type,_, let pageNum):
            switch type {
            case .following:
                return "/api/follow/following/\(pageNum)/\(10)"
            case .followers:
                return "/api/follow/followers/\(pageNum)/\(10)"
            case .blocked:
                return "/api/blocked/users/\(pageNum)/\(10)"
            case .reactions:
                return "/api/users/insights/recommended/reactions/users/\(pageNum)/\(10)"
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
        case .productDetail:
            return "/api/products/detail"
        case .notifications(let pageNum):
            return "/api/notice/\(pageNum)/\(10)"
        case .like:
            return "/api/liked"
        case .shoppingCart(let pageNum):
            return "/api/shoppingCart/\(pageNum)/\(10)"
        case .shoppingCartDelete(let productId):
            return "/api/shoppingCart/\(productId)"
        case .savedCllectionClassify:
            return "/api/users/saved/classify"
        case .savedCollection(let pageNum):
            return "/api/users/saved/lists/\(pageNum)/\(10)"
        case .interest:
            return "/api/interests/lists"
        case .updateUserInterest:
            return "/api/users/interests"
        case .similarProduct(_, let pageNum):
            return "/api/products/similar/\(pageNum)/\(10)"
        case .addShoppingCart:
            return "/api/shoppingCart"
        case .visualSearch:
            return "/api/discoversearch"
        case .search(let type,_, let pageNum):
            switch type {
            case .inApp:
                return "/api/products/search/\(pageNum)/\(10)"
            case .saved:
                return "/api/products/search/saved/\(pageNum)/\(10)"
            case .posted:
                return "/api/products/search/posts/\(pageNum)/\(10)"
            }
            
        case .categories:
            return "/api/categories"
        case .addProduct:
            return "/api/products"
        case .postProduct:
            return "/api/posts"
        case .insightsLiked(_,let pageNum):
            return "/api/users/insights/liked/\(pageNum)/10"
        case .insightsRecommend(_,let pageNum):
            return "/api/users/insights/recommended/users/\(pageNum)/10"
        case .logout:
            return "/api/users/logout"
        case .isNewUser:
            return "/api/users/is-new"
        case .reactionAnalysis:
            return "/api/users/insights/recommended/reactions/counts"
        case .deletePost(let postId):
            return "/api/posts/\(postId)"
        case .recommend:
            return "/api/recommends"
        case .reaction:
            return "/api/recommends/reactions"
        case .searchFacets:
            return "/api/search/facets"
        case .searchThemeClassify:
            return "/api/search/theme/classify"
        case .searchThemeHot(_,let page):
            return "/api/search/theme/\(page)/\(10)"
        case .searchYouMaylike(let page):
            return "/api/search/maylike/\(page)/\(10)"
        case .searchNew(let page):
            return "/api/search/new/\(page)/\(10)"
        case .globalSearch(_,_, let page):
            return "/api/search/global/\(page)/\(10)"
        case .searchThemeDetail(let themeId):
            return "/api/search/theme/detail/\(themeId)"
        case .searchThemeDetaiResource(_,let themeId, let page):
            return "/api/search/theme/resources/\(themeId)/\(page)/\(10)"
        case .searchThemeLabelDetaiResource(_, _, let page):
            return "/api/search/label/\(page)/\(10)"
        case .compareOffers:
            return "/api/products/offers"
        case .deleteNotice(let noticeId):
            return "/api/notice/\(noticeId)"
        case .makeRead:
            return "/api/read"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .saveCollection,
             .like,
             .uploadImage,
             .block,
             .follow,
             .updateUserInterest,
             .addShoppingCart,
             .visualSearch,
             .addProduct,
             .postProduct,
             .logout,
             .recommend,
             .reaction,
             .makeRead:
            return .post
        case .userDetail,.userPost,
             .userRecommend,
             .users,
             .insightPost,
             .insightRecommend,
             .insightsPostDetail,
             .insightsRecommendDetail,
             .reactions,
             .postDetail,
             .productDetail,
             .notifications,
             .shoppingCart,
             .savedCllectionClassify,
             .interest,
             .similarProduct,
             .search,
             .categories,
             .insightsRecommend,
             .insightsLiked,
             .isNewUser,
             .reactionAnalysis,
             .searchFacets,
             .searchThemeClassify,
             .searchThemeHot,
             .searchYouMaylike,
             .searchNew,
             .globalSearch,
             .searchThemeDetail,
             .searchThemeDetaiResource,
             .searchThemeLabelDetaiResource,
             .compareOffers:
            return .get
        case .modifyProfile:
            return .put
        case .undoFollow,.undoBlocked,.shoppingCartDelete,.deletePost,.deleteNotice:
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
        
        if loggedIn.value , let token = AuthManager.shared.token?.basicToken {
            header["Authorization"] = "Bearer \(token)"
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
        case .saveCollection(let param):
            params.merge(dict: param)
            
        case .like(let param):
            params.merge(dict: param)
        case .userPost(let userId, _),
             .userRecommend(let userId, _),
             .users(_, let userId, _):
            if userId.isNotEmpty {
                params["otherUserId"] = userId
            }
        case .userDetail(let userId):
            if let userId = userId , userId.isNotEmpty {
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
        case .interest(let level):
            params["level"] = level
        case .updateUserInterest(let ids):
            params["ids"] = ids
        case .postDetail(let postId):
            params["id"] = postId
        case .productDetail(let productId):
            params["productId"] = productId
        case .similarProduct(let param, _):
            params.merge(dict: param)
        case .addShoppingCart(let productId):
            params["productId"] = productId
        case .visualSearch(let param):
            params.merge(dict: param)
        case .search(_,let keywords, _):
            params["keywords"] = keywords
        case .addProduct(let param):
            params.merge(dict: param)
        case .postProduct(let param):
            params.merge(dict: param)
        case .insightsLiked(let postId, _):
            params["postId"] = postId
        case .insightsRecommend(let postId, _):
            params["postId"] = postId
        case .reactionAnalysis(let recommendId):
            params["recommendId"] = recommendId
        case .recommend(let param):
            params.merge(dict: param)
        case .reaction(let recommendId,let type):
            params["recommendId"] = recommendId
            params["type"] = type
        case .searchFacets(let query):
            params["query"] = query
        case .searchThemeHot(let classifyId, _):
            params["classifyId"] = classifyId
        case .globalSearch(let type, let keywords, _):
            params["query"] = keywords
            params["type"] = type.rawValue
        case .searchThemeDetaiResource(let type,_,_):
            params["type"] = type.rawValue
        case .searchThemeLabelDetaiResource(let type, let labelId, _):
            params["type"] = type.rawValue
            params["labelId"] = labelId
        case .compareOffers(let productId):
            params["productId"] = productId
        case .makeRead(let values):
            params.merge(dict: values)
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
        case .uploadImage(let type, let size ,let data):
            let fileName = dformatter.string(from: Date()) + ".jpeg"
            let formData = MultipartFormData(provider: MultipartFormData.FormDataProvider.data(data), name: "image", fileName: fileName, mimeType: "image/jpeg")
            return .uploadCompositeMultipart([formData], urlParameters: ["type" : type, "w" : size.width , "h" : size.height])
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
