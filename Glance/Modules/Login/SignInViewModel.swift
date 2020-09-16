//
//  SignInViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/25.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignInViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let instagram : Observable<Void>
    }
    
    struct Output {
        let instagramOAuth : Driver<Void>
        let tabbar : Driver<Void>
        let interest : Driver<Void>
    }
    

    func transform(input: Input) -> Output {
        
        let instagramOAuth = input.instagram.asDriver(onErrorJustReturn: ())
        let tabbar = PublishSubject<Void>()
        let interest = PublishSubject<Void>()
        let loadUserDetail = PublishSubject<Void>()
        
    
        AuthManager.shared.tokenChanged.filterNil()
            .delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMapLatest({ [weak self] (token) -> Observable<(RxSwift.Event<Bool>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.isNewUser()
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: {  event in
                switch event {
                case .next(let newUser):
                    if newUser {
                        interest.onNext(())
                    } else {
                        loadUserDetail.onNext(())
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        loadUserDetail.flatMapLatest({ [weak self] (isNewUser) -> Observable<(RxSwift.Event<User>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.userDetail(userId: "")
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: {  event in
            switch event {
            case .next(let (user)):
                user.save()
                tabbar.onNext(())
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        return Output(instagramOAuth: instagramOAuth,
                      tabbar: tabbar.asDriver(onErrorJustReturn: ()),
                      interest: interest.asDriver(onErrorJustReturn: ()))
    }
}

