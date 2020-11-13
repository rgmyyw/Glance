//
//  LogManager.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import CocoaLumberjack
import RxSwift

@inlinable
public func logDebug(_ message: @autoclosure () -> String) {
    DDLogDebug(message())
}

@inlinable
public func logError(_ message: @autoclosure () -> String) {
    DDLogError(message())
}

@inlinable
public func logInfo(_ message: @autoclosure () -> String) {
    DDLogInfo(message())
}

@inlinable
public func logVerbose(_ message: @autoclosure () -> String) {
    DDLogVerbose(message())
}

@inlinable
public func logWarn(_ message: @autoclosure () -> String) {
    DDLogWarn(message())
}

@inlinable
public func logResourcesCount() {
    #if DEBUG
    logDebug("RxSwift resources count: \(RxSwift.Resources.total)")
    #endif
}


