//
//  ModifyProfileViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CountryPickerView


class ModifyProfileViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let save : Observable<Void>
    }
    
    struct Output {
        let userHeadImageURL : Driver<URL?>
        let countryName : Driver<String>
    }
    

    let displayName = BehaviorRelay<String>(value: user.value?.displayName ?? "")
    let userName = BehaviorRelay<String>(value: user.value?.username ?? "")
    let instagram = BehaviorRelay<String>(value: user.value?.instagram ?? "")
    let website = BehaviorRelay<String>(value: user.value?.website ?? "")
    let bio = BehaviorRelay<String>(value: user.value?.bio ?? "")
    let country = BehaviorRelay<Country?>(value: nil)
    let selectedImage = BehaviorRelay<UIImage?>(value: nil)
    

    func transform(input: Input) -> Output {
            
        let userHeadImageURL = Observable.just(user.value?.userImage?.url).asDriver(onErrorJustReturn: nil)
        let countryName = Observable.just(user.value?.countryName ?? "").asDriver(onErrorJustReturn: "")
        let commit = PublishSubject<[String : Any]>()
        let uploadImage = PublishSubject<(UIImage, [String : Any])>()
        
        input.save.subscribe(onNext: { [weak self]() in
            
            self?.endEditing.onNext(())
            guard let userId = user.value?.userId else {
                self?.exceptionError.onNext(.general(message: "userId not empty"))
                return
            }

            guard let userName = self?.userName.value, userName.isNotEmpty else {
                self?.exceptionError.onNext(.general(message: "username not empty"))
                return
            }
            
            guard let displayName = self?.displayName.value, displayName.isNotEmpty else {
                self?.exceptionError.onNext(.general(message: "displayName not empty"))
                return
            }
            
            var data : [String : Any] = [String : Any]()
            data["userId"] = userId
            data["username"] = userName
            data["displayName"] = displayName
            
            if let country = self?.country.value {
                data["countryName"] = country.name
                data["countryCode"] = country.code
            }
            if let website = self?.website.value, website.isNotEmpty{
                data["website"] = website
            }
            if let bio = self?.bio.value ,bio.isNotEmpty{
                data["bio"] = bio
            }
            if let instagram = self?.instagram.value ,instagram.isNotEmpty {
                data["instagram"] = instagram
            }
            
            if let selectedImage = self?.selectedImage.value {
                uploadImage.onNext((selectedImage, data))
            } else {
                commit.onNext(data)
            }
        }).disposed(by: rx.disposeBag)
        
        uploadImage.flatMapLatest({ [weak self] (imageData,param) -> Observable<(RxSwift.Event<(String, [String : Any])>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                guard let data = imageData.jpegData(compressionQuality: 0.1) else { return  Observable.just(RxSwift.Event.completed) }
                return self.provider.uploadImage(type: UploadImageType.user.rawValue, data: data)
                    .trackActivity(self.loading)
                    .trackError(self.error)
                    .map { ($0,param)}
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let (url, param)):
                    var param = param
                    param["userImage"] = url
                    commit.onNext(param)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        commit.flatMapLatest({ [weak self] (data) -> Observable<(RxSwift.Event<User>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.modifyProfile(data: data)
                    .trackActivity(self.loading)
                    .trackError(self.error)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let item):
                    user.accept(item)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        
        
        return Output(userHeadImageURL: userHeadImageURL,countryName : countryName)
        
    }
}

