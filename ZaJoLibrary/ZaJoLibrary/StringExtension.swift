//
//  StringExtension.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


extension String {
    
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func substring(start: Int = 0, end:Int = -1) -> String {
        
        if (start == end) {
            return ""
        }
        else if (end != -1 && start > end) {
            fatalError("End should be larger than start")
        }
        else if (end < -1 || start < 0) {
            fatalError("End should be larger than 0")
        }
        else if start > self.count || end > self.count {
            fatalError("Index out of bound")
        }
        else {
            let startIdx = self.index(self.startIndex, offsetBy: start, limitedBy: self.endIndex)
            var endIdx: String.Index? = self.endIndex
            
            if end != -1 {
                endIdx = self.index(self.startIndex, offsetBy: end, limitedBy: self.endIndex)
            }
            
            return String(self[startIdx!..<endIdx!])
        }
    }
    
}

extension String {
    public subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

extension String {
    public func levenshtein(_ other: String) -> Int {
        let sCount = self.count
        let oCount = other.count
        
        guard sCount != 0 else {
            return oCount
        }
        
        guard oCount != 0 else {
            return sCount
        }
        
        let line : [Int]  = Array(repeating: 0, count: oCount + 1)
        var mat : [[Int]] = Array(repeating: line, count: sCount + 1)
        
        for i in 0...sCount {
            mat[i][0] = i
        }
        
        for j in 0...oCount {
            mat[0][j] = j
        }
        
        for j in 1...oCount {
            for i in 1...sCount {
                if self[i - 1] == other[j - 1] {
                    mat[i][j] = mat[i - 1][j - 1]       // no operation
                }
                else {
                    let del = mat[i - 1][j] + 1         // deletion
                    let ins = mat[i][j - 1] + 1         // insertion
                    let sub = mat[i - 1][j - 1] + 1     // substitution
                    mat[i][j] = min(min(del, ins), sub)
                }
            }
        }
        
        return mat[sCount][oCount]
    }
}
