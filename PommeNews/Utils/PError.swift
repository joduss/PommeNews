//
//  PError.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

enum PError {
    case HTTPErrorTimeout
    case HTTPErrorCode(Int)
    case HTTPErrorInvalidFormat
    case FeedFetchingError(NSError)
}
