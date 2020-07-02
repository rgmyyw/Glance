//
//  LogManager.swift
//  
//
//  Created by yanghai on 1/4/17.
//  Copyright © 2017 yanghai. All rights reserved.
//

import Foundation
import CocoaLumberjack
import RxSwift

public func logDebug(_ message: @autoclosure () -> String) {
    DDLogDebug(message())
}

public func logError(_ message: @autoclosure () -> String) {
    DDLogError(message())
}

public func logInfo(_ message: @autoclosure () -> String) {
    DDLogInfo(message())
}

public func logVerbose(_ message: @autoclosure () -> String) {
    DDLogVerbose(message())
}

public func logWarn(_ message: @autoclosure () -> String) {
    DDLogWarn(message())
}

public func logResourcesCount() {
    #if DEBUG
    logDebug("RxSwift resources count: \(RxSwift.Resources.total)")
    #endif
}
