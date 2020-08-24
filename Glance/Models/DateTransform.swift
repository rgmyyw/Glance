//
//  ISO8601DateTransform.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import ObjectMapper

open class DateTransform: TransformType {

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

extension Date {
    
    func customizedString() -> String {
        
        //获取当前的时间戳
        let currentTime = Date().timeIntervalSince1970
        //时间差
        let reduceTime : TimeInterval = currentTime - timeIntervalSince1970
        //时间差小于60秒
        if reduceTime < 60 {
            return "now"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins) minute ago"
        }
        //时间差大于一小时小于24小时内
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours) hour ago"
        }
        //时间差大于一天小于30天内
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days) day ago"
        }

        return dateString(ofStyle: .long)
    }

}

