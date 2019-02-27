//
//  PError.swift
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
    case FeedFetchingError(NSError)
    case MultiFeedFetchingError(PError)
    case inconsistency(String)
    case unsupported
    case dbIssue(String) 
}
