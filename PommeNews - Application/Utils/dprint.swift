//
//  dprint.swift
//  PommeNews
//
//  Created by Jonathan Duss on 01.01.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation
import os.log

enum Level {
    case debug
    case info
    case error
    case warning
}

func dprint(message: String, level: Level = .debug) {
    
    var type: OSLogType = OSLogType.default
    
    switch level {
    case .info:
        type = OSLogType.info
    case .error:
        type = OSLogType.error
    case .debug:
        type = OSLogType.debug
    case .warning:
        type = OSLogType.default
    }
    
    os_log(type, "%@", message)
}
