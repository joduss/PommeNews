//
//  ThemeRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 23.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

class ThemeRequest {
    
    func create() -> NSFetchRequest<Theme> {
        let request: NSFetchRequest<Theme> = Theme.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Theme.keyPropertyName, ascending: true)]
        return request
    }
    
}
