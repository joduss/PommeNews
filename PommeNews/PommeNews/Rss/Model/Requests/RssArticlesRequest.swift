//
//  RssArticlesRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 08.06.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

class RssArticlesRequest {
    
    public func create() -> NSFetchRequest<RssArticle> {
        let request: NSFetchRequest<RssArticle> = NSFetchRequest<RssArticle>(entityName: "RssArticle")
        request.sortDescriptors = [NSSortDescriptor(key: RssArticle.datePropertyName, ascending: false)];
        return request
    }
    
}
