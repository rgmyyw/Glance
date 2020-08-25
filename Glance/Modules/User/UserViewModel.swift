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



class UserViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let insight : Observable<Void>
        let setting : Observable<Void>
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

    }
    
    let settingSelectedItem = PublishSubject<SettingItem>()    
    
    func transform(input: Input) -> Output {
        
        let insight = input.insight.asDriver(onErrorJustReturn: ())
        let setting = input.setting.asDriver(onErrorJustReturn: ())
        let updateHeadLayout = PublishSubject<Void>()
        let signIn = PublishSubject<Void>()

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
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<User>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.userDetail(userId: "")
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: {  event in
                switch event {
                case .next(let item):
                    user.accept(item)
                    updateHeadLayout.onNext(())
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        let userHeadImageURL = user.map { $0?.userImage?.url}.asDriver(onErrorJustReturn: nil)
        let displayName = user.map { $0?.displayName ?? ""}.asDriver(onErrorJustReturn: "")
        let countryName = user.map { $0?.countryName ?? ""}.asDriver(onErrorJustReturn: "")
        let instagram = user.map { $0?.instagram ?? ""}.asDriver(onErrorJustReturn: "")
        let website = user.map { $0?.website ?? ""}.asDriver(onErrorJustReturn: "")
        let bio = user.map { $0?.bio ?? ""}.asDriver(onErrorJustReturn: "")
        
        let titles = user.filterNil().map { user -> [String] in
            return ["\(user.postCount)\nPost",
                "\(user.recommendCount)\nRecomm",
                "\(user.followerCount)\nFollowers",
                "\(user.followingCount)\nFollowing"]
        }.asDriver(onErrorJustReturn: ["0\nPost","0\nRecomm","0\nFollowers","0\nFollowing"])


        
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
                      privacy: privacy)
    }
}

