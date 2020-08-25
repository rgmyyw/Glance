//
//  ExceptionError.swift
//  
//
//  Created by 杨海 on 2020/4/4.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

enum ExceptionError: Error , CustomStringConvertible{
    
    case general(_ message: String)
    
    
    var description: String {
        switch self {
        case .general(let message):
            return message
        }
    }
    
    var asError: Error? {
        return self as Error
    }
}

extension Error {
    
    var asExceptionError: ExceptionError? {
        return self as? ExceptionError
    }

}
