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
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Date? {
        if let dateString = value as? String {
            return dateString.toISODate()?.date
        }
        return nil
    }

    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return date.toISO()
        }
        return nil
    }
}
