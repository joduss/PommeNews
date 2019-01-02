//
//  ThemeRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 23.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

class ThemeRequest: Request<Theme> {
    
    override func execute(context: NSManagedObjectContext) -> [Theme] {
        var result = super.execute(context: context)
        result.sort(by: { ($0.key.localized < $1.key.localized) && (sortOrder == . Ascending) })
        return result
    }
    
    override func execute(context: NSManagedObjectContext, completion: (([Theme]) -> ())) {
        super.execute(context: context,
                      completion: { themes in
                        var sortedThemes = themes
                        sortedThemes.sort(by: { ($0.key.localized < $1.key.localized) && (sortOrder == . Ascending) })
                        completion(sortedThemes)
        })
    }
    
}
