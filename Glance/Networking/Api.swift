//
//  Api.swift
//  
//
//  Created by yanghai on 1/5/18.
//  Copyright © 2018 yanghai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol API {
    func downloadString(url: URL) -> Single<String>
    func downloadFile(url: URL, fileName: String?) -> Single<Void>
}
