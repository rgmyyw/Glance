import Foundation
import RxSwift
import RxCocoa
import ObjectMapper


protocol API {
    
    func downloadString(url: URL) -> Single<String>
    func downloadFile(url: URL, fileName: String?) -> Single<Void>
    func getHome(page : Int) -> Single<PageMapable<DefaultColltionItem>>
    func userDetail(userId : String?) -> Single<User>
    func modifyProfile(data : [String : Any]) -> Single<User>
    func uploadImage(type: Int, size : CGSize, data : Data) -> Single<String>
    func userPost(userId : String, pageNum : Int) -> Single<PageMapable<DefaultColltionItem>>
    func userRecommend(userId : String, pageNum : Int) -> Single<PageMapable<DefaultColltionItem>>
    func users(type :  UsersType, userId : String, pageNum : Int) -> Single<PageMapable<User>>
    func follow(userId : String) -> Single<Bool>
    func undoFollow(userId : String) -> Single<Bool>
    func block(userId : String) -> Single<Bool>
    func undoBlocked(userId : String) -> Single<Bool>
    func insightPost(userId : String, pageNum : Int) -> Single<PageMapable<Insight>>
    func insightRecommend(userId : String, pageNum : Int) -> Single<PageMapable<Insight>>
    func insightsPostDetail(postId : Int) -> Single<InsightsDetail>
    func insightsrRecommendDetail(recommendId : Int) -> Single<InsightsDetail>
    func reactions(recommendId : Int,pageNum : Int) ->  Single<PageMapable<User>>
    func postDetail(postId : Int) -> Single<PostsDetail>
    func productDetail(productId : String) -> Single<PostsDetail>
    func notifications(pageNum : Int) -> Single<PageMapable<Notice>>
    func shoppingCart(pageNum : Int) -> Single<PageMapable<ShoppingCart>>
    func shoppingCartDelete(productId : String) -> Single<Bool>
    func like(param : [String : Any]) -> Single<Bool>
    func saveCollection(param : [String : Any]) -> Single<Bool>
    func savedCollection(pageNum : Int) ->  Single<PageMapable<DefaultColltionItem>>
    func savedCollectionClassify() -> Single<SavedCollection>
    func interest(level : Int) -> Single<[Interest]>
    func updateUserInterest(ids : String) -> Single<Bool>
    func similarProduct(params : [String : Any],page : Int) -> Single<PageMapable<DefaultColltionItem>>
    func addShoppingCart(productId : String) -> Single<Bool>
    func visualSearch(params : [String : Any]) -> Single<VisualSearchPageMapable>
    func productSearch(type : ProductSearchType,keywords : String, page : Int) -> Single<PageMapable<DefaultColltionItem>>
    func globalSearch(type : SearchResultContentType,keywords : String, page : Int) -> Single<PageMapable<DefaultColltionItem>>
    func categories()  -> Single<[Categories]>
    func addProduct(param : [String : Any]) -> Single<DefaultColltionItem>
    func postProduct(param : [String : Any]) -> Single<Bool>
    func insightsLiked(postId: Int,pageNum : Int) ->  Single<PageMapable<User>>
    func insightsRecommend(postId: Int,pageNum : Int) ->  Single<PageMapable<User>>
    func logout() -> Single<Bool>
    func isNewUser() -> Signal<Bool>
    func reactionAnalysis(recommendId : Int) -> Single<ReactionAnalysis>
    func deletePost(postId : Int) -> Single<Bool>
    func recommend(param : [String : Any]) -> Single<Bool>
    func reaction(recommendId : Int,type : Int) -> Single<Bool>
    func searchFacets(query : String) -> Single<[SearchFacet]>
    func searchThemeClassify() ->  Single<[SearchThemeClassify]>
    func searchThemeHot(classifyId : Int, page : Int) -> Single<PageMapable<SearchTheme>>
    func searchYouMaylike(page : Int) -> Single<PageMapable<DefaultColltionItem>>
    func searchNew(page : Int) -> Single<PageMapable<DefaultColltionItem>>
    func searchThemeDetail(themeId : Int) -> Single<SearchThemeDetail>
    func searchThemeDetaiResource(type : SearchThemeContentType,themeId : Int, page : Int) -> Single<PageMapable<DefaultColltionItem>>
    func searchThemeLabelDetaiResource(type : SearchThemeLabelContentType,labelId : Int, page : Int) -> Single<PageMapable<DefaultColltionItem>>
    func compareOffers(productId : String) -> Single<[SelectStore]>
}




