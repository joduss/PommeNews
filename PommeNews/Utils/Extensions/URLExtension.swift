//
//  URLExtension.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

extension URL {
    
    init?(string: String?) {
        guard let string = string else {
            return nil
        }
        self.init(string: string)
    }
}
