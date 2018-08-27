//
//  Theme+NamesProperties.swift
//  PommeNews
//
//  Created by Jonathan Duss on 23.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

extension Theme: EntityName {
    
    //==================================================
    static var entityName: String {
        return String(describing: Theme.self)
    }
    
    static var keyPropertyName: String {
        return "key"
    }
    
}
