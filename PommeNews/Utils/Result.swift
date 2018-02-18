//
//  Result.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


enum Result<T> {
    case failure(PError)
    case success(T)
}
