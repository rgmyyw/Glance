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
        
    }
    
    struct Output {
        
        let userHeadImageURL : Driver<URL?>
        let displayName : Driver<String>
        let countryName : Driver<String>
        let instagram : Driver<String>
        let website : Driver<String>
        let bio : Driver<String>
        
    }
    
    let settingSelectedItem = PublishSubject<SettingItem>()
    
    

    func transform(input: Input) -> Output {
        
        Observable.just(())
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<User>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.userDetail(userId: "")
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let item):
                    user.accept(item)
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
 
        
        return Output(userHeadImageURL: userHeadImageURL,displayName: displayName, countryName: countryName,instagram: instagram, website: website, bio: bio)
    }
}

