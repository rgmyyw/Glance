//
//  UserViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum UserNavigationAction : Int {
    case back = 0
    case share = 1
    case more = 2
    case insight = 3
    case setting = 4
    
}



struct UserDetailMemuItem {
    var type : UserDetailMemuType
    var title : String {
        return type.title
    }
}

enum UserDetailMemuType {
    case report
    case block
    
    var title : String {
        switch self {
        case .report:
            return "Report user"
        case .block:
            return "Block user"
        }
    }
    var image : UIImage? {
        switch self {
        case .report:
            return R.image.icon_button_report()
        case .block:
            return R.image.icon_button_report()
        }
    }
}

//struct UserModuleItem {
//    var viewModel : ViewModel
//}
//
enum UserModuleItem {
    
    case post(viewModel : UserPostViewModel)
    case recommend(viewModel : UserRecommViewModel)
    case followers(viewModel : UserRelationViewModel)
    case following(viewModel : UserRelationViewModel)
    
    var defaultTitle : String {
        switch self {
        case .post:
            return "0\nPosts"
        case .recommend:
            return "0\nRecomm"
        case .followers:
            return "0\nFollowers"
        case .following:
            return "0\nFollowing"
        }
    }
    
    func toScene(navigator : Navigator?) -> Navigator.Scene? {
        guard navigator != nil else {
            return nil
        }
        switch self {
        case .post(let viewModel):
            return .userPost(viewModel: viewModel)
        case .recommend(let viewModel):
            return .userRecommend(viewModel: viewModel)
        case .followers(let viewModel):
            return .userRelation(viewModel: viewModel)
        case .following(let viewModel):
            return .userRelation(viewModel: viewModel)
        }
    }
}


class UserViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let refresh: Observable<Void>
        let insight : Observable<Void>
        let setting : Observable<Void>
        let follow : Observable<Void>
        let chat : Observable<Void>
        let memu : Observable<Void>
    }
    
    struct Output {
        let userHeadImageURL : Driver<URL?>
        let displayName : Driver<String>
        let countryName : Driver<String>
        let instagram : Driver<String>
        let website : Driver<String>
        let bio : Driver<String>
        let titles : Driver<[String]>
        let updateHeadLayout : Driver<Void>
        let insight : Driver<Void>
        let setting : Driver<Void>
        let about : Observable<Void>
        let followAndInviteFriends : Observable<Void>
        let help : Observable<Void>
        let signIn : Observable<Void>
        let modifyProfile : Observable<Void>
        let notifications : Observable<Void>
        let originalPhotos : Observable<Void>
        let postsYourLiked : Observable<Void>
        let syncInstagram : Observable<Void>
        let privacy : Observable<Void>
        let navigationBarAvailable :  Observable<(left: [UserNavigationAction], right: [UserNavigationAction])>
        let otherUserBgViewHidden : Driver<Bool>
        let followButtonBackground : Driver<UIColor>
        let followButtonImage : Driver<UIImage?>
        let followButtonTitleColor : Driver<UIColor>
        let memu : Driver<[UserDetailMemuItem]>
        let config : Driver<[UserModuleItem]>
    }
    
    let current : BehaviorRelay<User?>
    
    init(provider: API, otherUser : User? = nil) {
        if let otherUser = otherUser , otherUser.userId != user.value?.userId{
            current = BehaviorRelay(value: otherUser)
        } else{
            current = user
        }

        super.init(provider: provider)
    }
    
    let settingSelectedItem = PublishSubject<SettingItem>()    
    
    func transform(input: Input) -> Output {
        
        let otherUserBgViewHidden = current.map { $0 == user.value }.asDriver(onErrorJustReturn: true)
        let userHeadImageURL = current.map { $0?.userImage?.url}.asDriver(onErrorJustReturn: nil)
        let displayName = current.map { $0?.displayName ?? ""}.asDriver(onErrorJustReturn: "")
        let countryName = current.map { $0?.countryName ?? ""}.asDriver(onErrorJustReturn: "")
        let instagram = current.map { $0?.instagram ?? ""}.asDriver(onErrorJustReturn: "")
        let website = current.map { $0?.website ?? ""}.asDriver(onErrorJustReturn: "")
        let bio = current.map { $0?.bio ?? ""}.asDriver(onErrorJustReturn: "")
        let followButtonBackground = current.map { ($0?.isFollow ?? false) ? UIColor.white : UIColor.primary() }
        let followButtonImage = current.map { ($0?.isFollow ?? false) ? nil : R.image.icon_button_add_noborder_white() }
        let followButtonTitleColor = current.map { ($0?.isFollow ?? false) ? UIColor.primary() : UIColor.white }
        input.chat.map { () in Message("Features under development...")}
            .bind(to: message).disposed(by: rx.disposeBag)

        
        let config = Observable<[UserModuleItem]>.create { (observer) -> Disposable in
            let user = self.current.value
            let post = UserPostViewModel(provider: self.provider, otherUser: user)
            let recommend = UserRecommViewModel(provider: self.provider, otherUser: user)
            let followers = UserRelationViewModel(provider: self.provider, type: .followers, otherUser: user)
            let following = UserRelationViewModel(provider: self.provider, type: .following, otherUser: user)
            let items : [UserModuleItem] = [.post(viewModel: post),.recommend(viewModel: recommend),
                                           .followers(viewModel: followers),.following(viewModel: following)]
            followers.parsedError.bind(to: self.parsedError).disposed(by: self.rx.disposeBag)
            following.parsedError.bind(to: self.parsedError).disposed(by: self.rx.disposeBag)

            observer.onNext(items)
            observer.onCompleted()
            return Disposables.create { }
        }
        
        let insight = input.insight.asDriver(onErrorJustReturn: ())
        let setting = input.setting.asDriver(onErrorJustReturn: ())
        let updateHeadLayout = current.mapToVoid().asDriver(onErrorJustReturn: ())
        let refresh = PublishSubject<Void>()
        let signIn = PublishSubject<Void>()
        let popMemu = input.memu.map { [UserDetailMemuItem(type: .report),UserDetailMemuItem(type: .block)] }.asDriver(onErrorJustReturn: [])

        let about = settingSelectedItem.filter { $0 == .about }.mapToVoid()
        let help = settingSelectedItem.filter { $0 == .help }.mapToVoid()
        let logout = settingSelectedItem.filter { $0 == .logout }.mapToVoid()
        let followAndInviteFriends = settingSelectedItem.filter { $0 == .followAndInviteFriends }.mapToVoid()
        let modifyProfile = settingSelectedItem.filter { $0 == .modifyProfile }.mapToVoid()
        let notifications = settingSelectedItem.filter { $0 == .notifications }.mapToVoid()
        let originalPhotos = settingSelectedItem.filter { $0 == .originalPhotos }.mapToVoid()
        let postsYourLiked = settingSelectedItem.filter { $0 == .postsYourLiked }.mapToVoid()
        let syncInstagram = settingSelectedItem.filter { $0 == .syncInstagram }.mapToVoid()
        let privacy = settingSelectedItem.filter { $0 == .privacy }.mapToVoid()
        let navigationBarAvailable = current.map { $0?.userId == user.value?.userId }
            .map { current -> (left : [UserNavigationAction], right : [UserNavigationAction] ) in
                if current {
                    return ([.insight], [.setting,.share])
                } else {
                    return ([.back], [.more,.share])
                }
        }
        
        
        logout.flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<Bool>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.logout()
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { [weak self]  event in
            switch event {
            case .next(let result):
                if result {
                    AuthManager.removeToken()
                    User.removeCurrentUser()
                    signIn.onNext(())
                } else {
                    self?.exceptionError.onNext(.general("logout request return false"))
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        input.refresh.merge(with: refresh).flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<User>)> in
            
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.userDetail(userId: self.current.value?.userId ?? "")
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let item):
                self?.current.accept(item)
                if user.value == nil {
                    item.save()
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
    
        input.follow.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<Bool>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let isFollow = self.current.value?.isFollow ?? false
            let userId = self.current.value?.userId ?? ""
            let request = isFollow ? self.provider.undoFollow(userId: userId) : self.provider.follow(userId: userId)
            return request
                .trackActivity(self.loading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            switch event {
            case .next(let result):
                var current = self?.current.value
                current?.isFollow = result
                self?.current.accept(current)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        
        let titles = current.filterNil().map { user -> [String] in
            return ["\(user.postCount)\nPosts",
                "\(user.recommendCount)\nRecomm",
                "\(user.followerCount)\nFollowers",
                "\(user.followingCount)\nFollowing"]
        }.asDriver(onErrorJustReturn: ["0\nPosts","0\nRecomm","0\nFollowers","0\nFollowing"])
        
        
        kUpdateItem.subscribe(onNext: { (state, item,trigger) in
            switch state {
            case .delete:
                refresh.onNext(())
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        return Output(userHeadImageURL: userHeadImageURL,
                      displayName: displayName,
                      countryName: countryName,
                      instagram: instagram,
                      website: website,
                      bio: bio,
                      titles: titles,
                      updateHeadLayout: updateHeadLayout.asDriver(onErrorJustReturn: ()),
                      insight: insight ,
                      setting: setting,
                      about: about,
                      followAndInviteFriends: followAndInviteFriends,
                      help: help,
                      signIn: signIn,
                      modifyProfile: modifyProfile,
                      notifications: notifications,
                      originalPhotos:originalPhotos,
                      postsYourLiked: postsYourLiked,
                      syncInstagram: syncInstagram ,
                      privacy: privacy,
                      navigationBarAvailable: navigationBarAvailable,
                      otherUserBgViewHidden: otherUserBgViewHidden,
                      followButtonBackground: followButtonBackground.asDriver(onErrorJustReturn: .white),
                      followButtonImage: followButtonImage.asDriver(onErrorJustReturn: nil),
                      followButtonTitleColor: followButtonTitleColor.asDriver(onErrorJustReturn: .white),
                      memu: popMemu,
                      config: config.asDriver(onErrorJustReturn: []) )
    }
    
 
    
}

