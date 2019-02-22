//
//  RssArticlesByThemesRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 25.10.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

//extension ArticleRequest {
//    
//    func a() {
//        self.request
//    }
//}

class RssArticlesByThemesRequest {
    
    
    private let request: NSFetchRequest<RssArticle>

    ///Also include articles from hidden RSSFeed?
    var showHidden = false
    
    
    init(fromRequest request: NSFetchRequest<RssArticle>) {
        self.request = request
    }
    
    func create(withThemes themes: [Theme]) -> NSFetchRequest<RssArticle> {
        
        var themesPredicates: [NSPredicate] = []
        
        for theme in themes {
            themesPredicates.append(NSPredicate(format: "ANY themes == %@", theme))
        }
        
        if let existingPredicates = request.predicate {
            let themePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: themesPredicates)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [themePredicate, existingPredicates])
        }
        else {
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: themesPredicates)

        }

        if showHidden == false {
            let nonHiddenFeed = NSPredicate(format: "feed == %@", false)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [request.predicate!, nonHiddenFeed])
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: RssArticle.datePropertyName, ascending: false)]
        
        return request
    }
    
    
    
}
