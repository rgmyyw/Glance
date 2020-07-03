//
//  Foundation+.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import Foundation

extension Int {
    
    func sizeFromKB() -> String {
        return (self*1024).sizeFromByte()
    }
    
    func sizeFromByte() -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }
    
    func kFormatted() -> String {
        let sign = ((self < 0) ? "-" : "" )
        if self < 1000 {
            return "\(sign)\(self)"
        }
        let num = fabs(self.double)
        let exp: Int = Int(log10(num) / 3.0 ) //log10(1000))
        let units: [String] = ["K", "M", "G", "T", "P", "E"]
        let roundedNum: Double = round(10 * num / pow(1000.0, Double(exp))) / 10
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
    
    /// 秒数转化为时间字符串
    func timeString() -> String {
        let seconds = self
        let days = (seconds) / (24 * 3600)
        let hours = (seconds) % (24 * 3600) / 3600
        let minutes = (seconds) % 3600 / 60
        let second = (seconds) % 60
        let timeString  = String(format: "%lu天 %02lu:%02lu:%02lu", days, hours, minutes, second)
        return timeString
    }
    
}



extension String {
    
    var isValidPassword: Bool {
        return matches(pattern: "^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,16}")
    }
    
    var isValidNickName: Bool {
        return self.count >= 2 && self.count <= 16
    }
    
    
    var isValidPostalCode : Bool {
        return matches(pattern: "^[0-8]\\d{5}(?!\\d)$")
    }
    
    var isValidPhoneNumber : Bool {
        return matches(pattern: "^1\\d{10}$")
    }
    
    func toHTMLString() -> String {
        let html = self
        let str = "<img style='display: block; max-width: 100%;'"
        let htmlstring = (html as NSString).replacingOccurrences(of: "<img", with: str)
        let htmlText = "<html><head><meta http-equiv=\'Content-Type\' content=\'text/html; charset=utf-8\'/><meta content=\'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;\' name=\'viewport\' /><meta name=\'apple-mobile-web-app-capable\' content=\'yes\'><meta name=\'apple-mobile-web-app-status-bar-style\' content=\'black\'><link rel=\'stylesheet\' type=\'text/css\' /><style type=\'text/css\'> .color{color:#576b95;}</style></head><body><div id=\'content\'>\(htmlstring)</div>"
        return htmlText
    }
}

extension Dictionary {
    
    /// 合并 Dictionary
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    
}


infix operator +

func + (param1 : [String : Any], param2 : [String : Any])-> [String : Any]{
    var param = [String  : Any]()
    param.merge(dict: param1)
    param.merge(dict: param2)
    return param
}




extension Array {
    
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    
}

extension Array where Element:Hashable {
    
    var unique:[Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(self.count)
        return self.filter {
            return uniq.insert($0).inserted
        }
    }
}


extension Int {
    
    var milliDate: Date {
        return Date(milliseconds: self)
    }
    
    
    /// Date String : yyyy-MM-dd-HH-mm
    var dateString: String? {
        return milliDate.string(withFormat: "yyyy-MM-dd-HH:mm")
    }
    
    var dateInterval : DateComponents? {
        let date1 = Date()
        let date2 : Date = string.count > 10 ? Date(milliseconds: self) : Date(seconds: self.double)
        return Calendar.current.dateComponents([.day,.hour,.minute], from: date1, to: date2)
    }
}

extension String {
    
    /// Date String : yyyy-MM-dd-HH-mm
    var dateString : String? {
        guard let milli = self.int else {
            return nil
        }
        return milli.milliDate.string(withFormat: "yyyy-MM-dd-HH:mm")
    }
    
}
