//
//  ExceptionError.swift
//  
//
//  Created by 杨海 on 2020/4/4.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import Moya

enum ExceptionError: Error , CustomDebugStringConvertible,CustomStringConvertible {
    
    case general(_ message: String)
    case unknown
    case argumentOutOfRange
    case timeout
    case empty
    case jsonMapping(response : Response)
//    case noMore
    
    var asError: Error? {
        return self as Error
    }
}

extension Error {
    
    var asExceptionError: ExceptionError? {
        return self as? ExceptionError
    }
}
extension ExceptionError {
    
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown error occurred."
        case .argumentOutOfRange:
            return "Argument out of range."
        case .timeout:
            return "timeout."
        case .empty:
            return "no result"
        case .jsonMapping:
            return "JSON Mapping error"
        case .general(let text):
            return "Error: \(text)"
//        case .noMore:
//            return "no more update!"
        }

    }
    
    public var debugDescription: String {
        return description
    }
}
