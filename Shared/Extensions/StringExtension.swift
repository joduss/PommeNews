//
//  StringExtension.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func substring(start: Int = 0, end:Int = -1) -> String {
        
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
