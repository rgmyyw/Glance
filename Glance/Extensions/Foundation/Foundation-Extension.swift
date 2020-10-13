//
//  Foundation+.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import UIKit


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





extension String {
    
    func urlParameters() -> [String: String]? {
        var params: [String: String] = [:]
        let array = self.components(separatedBy: "?")
        if array.count == 2 {
            let paramsStr = array[1]
            if paramsStr.count > 0 {
                let paramsArray = paramsStr.components(separatedBy: "&")
                for param in paramsArray {
                    let arr = param.components(separatedBy: "=")
                    if arr.count == 2 {
                        params[arr[0]] = arr[1]
                    }
                }
            }
        }
        return params
    }
    
}

extension UILabel {
    
    func boundingRect(size : CGSize) -> CGSize {
        guard let text = self.text  else {
            return .zero
        }
        return text.boundingRect(with: size, font: font)
    }
    
}


extension String {
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil) -> CGSize {
        let attritube = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attritube.length)
        attritube.addAttributes([NSAttributedString.Key.font: font], range: range)
        if lineSpacing != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing!
            attritube.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        }
        
        let rect = attritube.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        var size = rect.size
        
        if let currentLineSpacing = lineSpacing {
            // 文本的高度减去字体高度小于等于行间距，判断为当前只有1行
            let spacing = size.height - font.lineHeight
            if spacing <= currentLineSpacing && spacing > 0 {
                size = CGSize(width: size.width, height: font.lineHeight)
            }
        }
        return size
    }
    
}

extension NSNotification.Name {
 
    public static let kUpdateHomeData : NSNotification.Name = NSNotification.Name("kUpdateHomeData")
    public static let kRemovePostItem : NSNotification.Name = NSNotification.Name("kRemovePostItem")
    public static let kAddProduct : NSNotification.Name = NSNotification.Name("kAddProduct")

}

extension String {
    
    func urlImageSize(nan : CGFloat = 200) -> CGSize {
        if let urlParameters = self.urlParameters() , urlParameters.isNotEmpty {
            guard let width = urlParameters["w"]?.cgFloat(), !width.isNaN else {
                return .zero
            }
            guard let height = urlParameters["h"]?.cgFloat() ,!height.isNaN else {
                return .zero
            }
            return CGSize(width: width, height: height)
        } else {
            return .zero
        }

    }
}

protocol CollectionCellImageHeightCalculateable {
    var image : String? { get }
    var imageHeight : CGFloat { get }
    var col : Int  { get}
    var inset : CGFloat { get }
    var itemInset : CGFloat { get }
    var defaultHeight : CGFloat { get }
}

extension CollectionCellImageHeightCalculateable {
    
    var inset : CGFloat {
        return 20
    }
    
    var itemInset : CGFloat {
        return 15
    }
    var defaultHeight : CGFloat {
        return 200
    }
    
    var imageHeight : CGFloat {
        let cellWidth : CGFloat = UIScreen.width - (inset * 2.0) - ((col.cgFloat - 1.0) * itemInset)
        if let size =  image?.urlImageSize() , size != .zero {
            return ((cellWidth / size.width) * size.height) / col.cgFloat
        } else {
            return defaultHeight
        }
    }
    
}


extension NSObject {
    public var className: String {
        return type(of: self).className
    }

    public static var className: String {
        return String(describing: self)
    }
}

extension String {
    
    public subscript(integerIndex: Int) -> Character {
        let index = self.index(startIndex, offsetBy: integerIndex)
        return self[index]
    }
    
    public subscript(integerRange: Range<Int>) -> String {
        let start = self.index(startIndex, offsetBy: integerRange.lowerBound)
        let end = self.index(startIndex, offsetBy: integerRange.upperBound)
        return String(self[start..<end])
    }
    
    
    public subscript(integerClosedRange: ClosedRange<Int>) -> String {
        return self[integerClosedRange.lowerBound..<(integerClosedRange.upperBound + 1)]
    }

}

extension Int {
    
    enum IntFormat {
        case k
        var value : CGFloat {
            switch self {
            case .k:
                return 1000.0
            }
        }
        
        var format : String {
            switch self {
            case .k:
                return "k"
            }
        }
    }
    
    func format(f : IntFormat = .k) -> String {
        let i = self.cgFloat
        let n = i / f.value
        if n > 999 {
            return String(format: "%.2lf\(f.format)", n)
        } else {
            return self.string
        }
    }
    
}

