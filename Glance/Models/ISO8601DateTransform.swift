//
//  ISO8601DateTransform.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import ObjectMapper

open class ISO8601DateTransform: TransformType {

    public typealias Object = Date
    public typealias JSON = Int

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Date? {
        if let i = value as? Int {
            return (i * 1000).milliDate
        }
        return nil
    }

    open func transformToJSON(_ value: Date?) -> Int? {
        if let date = value {
            return date.timeIntervalSince1970.int
        }
        return nil
    }
}
