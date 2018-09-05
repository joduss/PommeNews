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
    
}
