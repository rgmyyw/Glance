//
//  BadgeValueManager.swift
//  Glance
//
//  Created by yanghai on 2020/11/19.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum BadgeValueType {
    case notice(id: Int)
    case message(id: Int)
    case update

    var type: Int {
        switch self {
        case .notice:
            return 0
        case .message:
            return 1
        case .update:
            return -1
        }
    }
}

class BadgeValueManager: NSObject {

    private let provider: API

    static let shared = BadgeValueManager()
    private override init() {
        provider = RestApi(ibexProvider: IbexNetworking.ibexNetworking())
        super.init()
    }

    func setup() {
        NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .mapToVoid().merge(with: user.filterNil().mapToVoid()
                .delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance))
            .subscribe(onNext: { () in
                BadgeValueManager.shared.makeRead(type: .update)
            }).disposed(by: rx.disposeBag)
    }

    @discardableResult
    func makeRead(type: BadgeValueType) -> Observable<Bool> {
        if !loggedIn.value { return Observable.just(false)}
        let complete = PublishSubject<Bool>()
        var values = ["type": type.type]
        switch type {
        case .message(let id):
            values["messageId"] = id
        case .notice(let id):
            values["noticeId"] = id
        case .update:
            values = [:]
        }
        provider.makeRead(values: values).asObservable()
            .subscribe(onNext: { (item) in
                complete.onNext(true)
                UIApplication.shared.applicationIconBadgeNumber = item.app
                NotificationCenter.default.post(name: .kUpdateBageValue, object: nil, userInfo: item.toJSON())
        }).disposed(by: self.rx.disposeBag)

        return complete
    }

}
