//
//  Result.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


public enum Result<T, E> {
    case failure(E)
    case success(T)
}

public extension Result where T == Void {
    public static var success: Result {
        return .success(())
    }
}
