//
//  ViewModelType.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

enum RefreshState {
    case enable
    case disable
    case noMoreData
    case end
    case begin
}

class ViewModel: NSObject {

    let provider: API

    var page = 1

    let loading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()
    let refreshState = PublishSubject<RefreshState>()

    let error = ErrorTracker()
    let parsedError = PublishSubject<ApiError>()
    let exceptionError = PublishSubject<ExceptionError?>()
    let message = PublishSubject<Message>()
    let endEditing = PublishSubject<Void>()

    init(provider: API) {
        self.provider = provider
        super.init()

        error.asObservable().map { (error) -> ApiError? in
            do {
                let errorResponse = error as? MoyaError
                if let body = try errorResponse?.response?.mapJSON() as? [String: Any],
                    let errorResponse = Mapper<ErrorModel>().map(JSON: body) {
                    var errors = ErrorResponse(JSON: [:])!
                    errors.errors = [errorResponse]
                    return ApiError.serverError(response: errors)
                }
            } catch {
                print(error)
            }
            return nil
        }.filterNil().bind(to: parsedError).disposed(by: rx.disposeBag)

        error.asDriver().drive(onNext: { (error) in
            logError("\(error)")
        }).disposed(by: rx.disposeBag)

        exceptionError.filterNil().subscribe(onNext: { message in
            logError(message.description)
        }).disposed(by: rx.disposeBag)
    }

    deinit {
        logDebug("\(type(of: self)): Deinited")
        //logResourcesCount()
    }
}
