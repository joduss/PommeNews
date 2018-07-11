//
//  RssFeedRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 10.07.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData


class RssFeedRequest {
    
    private var showHidden = true
    
    func showHidden(_ value: Bool) -> RssFeedRequest {
        showHidden = value
        return self
    }
    
    func create() -> NSFetchRequest<RssFeed> {
        let request: NSFetchRequest<RssFeed> = RssFeed.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: RssFeed.namePropertyName, ascending: true)]
        if showHidden == false {
            request.predicate = NSPredicate(format: "hidden=%@", NSNumber(value: false))
        }
        return request
    }
    
}
