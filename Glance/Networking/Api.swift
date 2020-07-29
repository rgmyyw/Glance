import Foundation
import RxSwift
import RxCocoa
import ObjectMapper


enum UploadImageType : Int {
    case visualSearch = 0
    case post = 1
    case postDraft = 2
    case user = 3
}

struct UploadImageResult: Mappable {
    var imageUri: String?
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        imageUri   <- map["imageUri"]
    }
}

protocol API {
    
    func downloadString(url: URL) -> Single<String>
    func downloadFile(url: URL, fileName: String?) -> Single<Void>
    func getHome(page : Int) -> Single<PageMapable<Home>>
    func userDetail(userId : String) -> Single<User>
    func modifyProfile(data : [String : Any]) -> Single<User>
    func uploadImage(type: Int, size : CGSize, data : Data) -> Single<String>
    func userPost(userId : String, pageNum : Int) -> Single<PageMapable<Home>>
    func userRecommend(userId : String, pageNum : Int) -> Single<PageMapable<Home>>
    func userRelation(type :  UserRelationType, userId : String, pageNum : Int) -> Single<PageMapable<UserRelation>>
    func follow(userId : String) -> Single<Bool>
    func undoFollow(userId : String) -> Single<Bool>
    func block(userId : String) -> Single<Bool>
    func undoBlocked(userId : String) -> Single<Bool>
    func insightPost(userId : String, pageNum : Int) -> Single<PageMapable<Insight>>
    func insightRecommend(userId : String, pageNum : Int) -> Single<PageMapable<Insight>>
    func insightsPostDetail(postId : Int) -> Single<InsightsDetail>
    func insightsrRecommendDetail(recommendId : Int) -> Single<InsightsDetail>
    func reactions(recommendId : Int,pageNum : Int) ->  Single<PageMapable<Reaction>>
    func detail(id : Any, type : Int) -> Single<PostsDetail>
    func notifications(pageNum : Int) -> Single<PageMapable<Notification>>
    func shoppingCart(pageNum : Int) -> Single<PageMapable<ShoppingCart>>
    func shoppingCartDelete(productId : String) -> Single<Bool>
    func like(id : Any, type : Int, state : Bool) -> Single<Bool>
    func saveCollection(param : [String : Any]) -> Single<Bool>
    func savedCollection(pageNum : Int) ->  Single<PageMapable<Home>>
    func savedCollectionClassify() -> Single<SavedCollection>
    func interest(level : Int) -> Single<[Interest]>
    func updateUserInterest(ids : String) -> Single<Bool>
    func similarProduct(id : Any, type : Int,page : Int) -> Single<PageMapable<PostsDetailProduct>>
    func addShoppingCart(productId : String) -> Single<Bool>
    //func recommend(id : Any, type : Int, state : Bool) -> Single<Bool>

}




