//
//  RCrror.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

public indirect enum PError: Error {
    
    case HTTPErrorTimeout(String)
    case HTTPErrorCode(String, Int)
    case HTTPErrorInvalidFormat
    
    case FetchingError(NSError)
    case MultiFetchingError(PError)
    
    case inconsistency(String)
    case dbIssue(String)

    case illegalOperation(String)
    case unsupported
}
