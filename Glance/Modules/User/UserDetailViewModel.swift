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

class UserDetailViewModel: ViewModel, ViewModelType {
    
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
        let navigationBarAvailable :  Observable<(left: [UserDetailNavigationAction], right: [UserDetailNavigationAction])>
        let otherUserBgViewHidden : Driver<Bool>
        let followButtonBackground : Driver<UIColor>
        let followButtonImage : Driver<UIImage?>
        let followButtonTitleColor : Driver<UIColor>
        let followButtonTitle : Driver<String>
        let memu : Driver<[UserDetailMemuItem]>
        let config : Driver<[UserModuleItem]>
    }
    
    
    let otherUser = BehaviorRelay<User?>(value: nil)
    let element : BehaviorRelay<User?>
    let userMode : BehaviorRelay<UserDetailMode>
    
    
    init(provider: API, otherUser : User? = nil) {
        if let otherUser = otherUser {
            element = BehaviorRelay(value: otherUser)
            userMode = BehaviorRelay(value: .other)
            self.otherUser.accept(otherUser)
        } else{
            
            element = BehaviorRelay(value: user.value)
            userMode = BehaviorRelay(value: .current)
            self.otherUser.accept(nil)
        }
        super.init(provider: provider)
    }
    
    let settingSelectedItem = PublishSubject<SettingItem>()    
    
    func transform(input: Input) -> Output {
        
        let otherUserBgViewHidden = userMode.map { $0 == .current }.asDriver(onErrorJustReturn: true)
        let userHeadImageURL = element.map { $0?.userImage?.url }
        let displayName = element.map { $0?.displayName ?? ""}
        let countryName = element.map { "  \($0?.countryName ?? "")"}
        let instagram = element.map { $0?.igHandler ?? ""}
        let website = element.map { $0?.website ?? ""}
        let bio = element.map { $0?.bio ?? ""}
        let followButtonBackground = element.map { ($0?.isFollow ?? false) ? UIColor.white : UIColor.primary() }
        let followButtonImage = element.map { ($0?.isFollow ?? false) ? nil : R.image.icon_button_add_noborder_white() }
        let followButtonTitleColor = element.map { ($0?.isFollow ?? false) ? UIColor.primary() : UIColor.white }
        let followButtonTitle = element.map { ($0?.isFollow ?? false) ? "Following" : " Follow" }
        let insight = input.insight.asDriver(onErrorJustReturn: ())
        let setting = input.setting.asDriver(onErrorJustReturn: ())
        let updateHeadLayout = element.mapToVoid().asDriver(onErrorJustReturn: ())
        let refresh = PublishSubject<Void>()
        let signIn = PublishSubject<Void>()
        let popMemu = input.memu.map { [UserDetailMemuItem(type: .report),UserDetailMemuItem(type: .block)] }
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
        let titles = PublishSubject<[String]>()
        let updateTitle = PublishSubject<[UserDetailUpdateTitle]>()
        
        updateTitle.subscribe(onNext: { [weak self] (items) in
            var t = self?.element.value
            items.forEach { (i) in
                switch i {
                case .post(let count):
                    t?.postCount = count
                case .recommend(let count):
                    t?.recommendCount = count
                case .followers(let count):
                    t?.followerCount = count
                case .following(let count):
                    t?.followingCount = count
                }
            }
            self?.element.accept(t)
        }).disposed(by: rx.disposeBag)
        
        element.filterNil().map {
            ["\($0.postCount)\nPosts",
                "\($0.recommendCount)\nRecomm",
                "\($0.followerCount)\nFollowers",
                "\($0.followingCount)\nFollowing"]
        }.bind(to: titles)
            .disposed(by: rx.disposeBag)
        
        
        let navigationBarAvailable = userMode
            .map { mode -> (left : [UserDetailNavigationAction], right : [UserDetailNavigationAction] ) in
                if mode == .current {
                    return ([.insight], [.setting,.share])
                } else {
                    return ([.back], [.more,.share])
                }
        }
        
        
        let config = Observable<[UserModuleItem]>.create { (observer) -> Disposable in
            let user = self.otherUser.value.value
            
            let post = UserDetailPostViewModel(provider: self.provider, otherUser: user)
            let recommend = UserDetailRecommViewModel(provider: self.provider, otherUser: user)
            let followers = UsersViewModel(provider: self.provider, type: .followers, otherUser: user)
            let following = UsersViewModel(provider: self.provider, type: .following, otherUser: user)
            let items : [UserModuleItem] = [.post(viewModel: post),.recommend(viewModel: recommend),
                                            .followers(viewModel: followers),.following(viewModel: following)]
            
            if self.userMode.value == .current {
                recommend.needUpdateTitle.map {
                    let count = self.element.value?.recommendCount ?? 0
                    let item = UserDetailUpdateTitle.recommend(count: $0 ? count + 1 : count - 1)
                    return [item]
                }.bind(to: updateTitle).disposed(by: self.rx.disposeBag)
                
                followers.needUpdateTitle.merge(with: following.needUpdateTitle).map {
                    let count = self.element.value?.followingCount ?? 0
                    let item = UserDetailUpdateTitle.following(count: $0 ? count + 1 : count - 1)
                    return [item]
                }.bind(to: updateTitle).disposed(by: self.rx.disposeBag)
            }
            
            observer.onNext(items)
            observer.onCompleted()
            return Disposables.create { }
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
            let current = self.userMode.value == .current
            let userId = current ? nil : self.otherUser.value?.userId
            return self.provider.userDetail(userId: userId)
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let item):
                self?.element.accept(item)
                if self?.userMode.value == .current {
                    item.save()
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        input.follow.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<Bool>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let isFollow = self.element.value?.isFollow ?? false
            let userId = self.element.value?.userId ?? ""
            let request = isFollow ? self.provider.undoFollow(userId: userId) : self.provider.follow(userId: userId)
            return request
                .trackActivity(self.loading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            switch event {
            case .next(let result):
                let count = self?.element.value?.followerCount ?? 0
                var element = self?.element.value
                element?.isFollow = result
                element?.followerCount = result ? count + 1 : count - 1
                self?.element.accept(element)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        input.chat.map { () in Message("Features under development...")}
            .bind(to: message).disposed(by: rx.disposeBag)
        
        
//        kUpdateItem.subscribe(onNext: { (state, item,trigger) in
//            switch state {
//            case .delete:
//                refresh.onNext(())
//            default:
//                break
//            }
//        }).disposed(by: rx.disposeBag)
        
        
        return Output(userHeadImageURL: userHeadImageURL.asDriver(onErrorJustReturn: nil),
                      displayName: displayName.asDriver(onErrorJustReturn: ""),
                      countryName: countryName.asDriver(onErrorJustReturn: ""),
                      instagram: instagram.asDriver(onErrorJustReturn: ""),
                      website: website.asDriver(onErrorJustReturn: ""),
                      bio: bio.asDriver(onErrorJustReturn: ""),
                      titles: titles.asDriver(onErrorJustReturn: []),
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
                      followButtonTitle: followButtonTitle.asDriver(onErrorJustReturn: ""),
                      memu: popMemu.asDriver(onErrorJustReturn: []),
                      config: config.asDriver(onErrorJustReturn: []) )
    }
    
    
    
}

