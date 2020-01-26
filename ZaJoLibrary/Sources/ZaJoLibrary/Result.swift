//
//  Result.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


//public enum Result<T, E> where E: Error {
//    case failure(E)
//    case success(T)
//}
//
/////Extension created to allow writing "Result.success"
public extension Result where Success == Void {
    static var success: Result {
        return .success(())
    }
}


