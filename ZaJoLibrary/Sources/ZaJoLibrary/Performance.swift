//
//  Performance.swift
//  ZaJoLibrary-iOS
//
//  Created by Jonathan Duss on 07.03.19.
//

import Foundation

public class Performance {
    
    public static func measure(title: String = "Operation", code: () -> ()) {
        let start = Date()
        code()
        let stop = Date()
        
        let seconds = stop.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        
        if seconds < pow(10,-6) {
            NSLog("\(title) took \(seconds / pow(10,-9)) nanoseconds")
        }
        else if seconds < 100 {
            NSLog("\(title) took \(seconds / pow(10,-3)) milliseconds")
        }
        else {
            NSLog("\(title) took \(seconds) seconds")
        }
    }
    
}
