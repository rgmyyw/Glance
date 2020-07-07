import Foundation
import RxSwift
import RxCocoa
import ObjectMapper



protocol API {
    
    func downloadString(url: URL) -> Single<String>
    func downloadFile(url: URL, fileName: String?) -> Single<Void>
    func getHome(page : Int) -> Single<PageMapable<Home>>
    func saveFavorite(id : Any, type : Int) -> Single<Bool>
}




