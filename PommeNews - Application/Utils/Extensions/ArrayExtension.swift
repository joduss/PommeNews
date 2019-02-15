//
//  ArrayExtension.swift
//  PommeNews
//
//  Created by Jonathan Duss on 03.02.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation


extension Array where Element: Comparable {
    
    
    public func isSame(asArray array: Array) -> Bool {
        
        guard self.count + array.count != 0 else { return true }
        guard self.count == array.count else { return false }
        
        let arrayA = self.sorted()
        let arrayB = array.sorted()
        
        for i in 0..<self.count {
            if arrayA[i] != arrayB[i] {
                return false
            }
        }
        return true
    }
    
}
