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
    func uploadImage(type: Int, data : Data) -> Single<String>
    func userPost(userId : String, pageNum : Int) -> Single<PageMapable<Posts>>
    func userRecommend(userId : String, pageNum : Int) -> Single<PageMapable<Recommend>>
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
    func postDetail(postId : Int) -> Single<PostsDetail>
    func collect(id : [String : Any], type : Int, state : Bool) -> Single<Bool>

}




