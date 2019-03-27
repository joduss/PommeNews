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
    
    private var showHidden: Bool = false
    private var addedByUser: Bool? = nil
    
    func showHidden(_ value: Bool) -> RssFeedRequest {
        showHidden = value
        return self
    }
    
    func addedByUser(_ value: Bool?) -> RssFeedRequest {
        addedByUser = value
        return self
    }
    
    func create() -> NSFetchRequest<RssFeed> {
        let request: NSFetchRequest<RssFeed> = RssFeed.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: RssFeed.namePropertyName, ascending: true)]
        request.predicate = createPredicate()
        return request
    }
    
    private func createPredicate() -> NSPredicate {
        var predicates : [NSPredicate] = []
        if showHidden == false {
            predicates.append(NSPredicate(format: "hidden=%@", NSNumber(value: false)))
        }
        if let addedByUser = self.addedByUser {
            predicates.append(NSPredicate(format: "addedByUser=%@", NSNumber(value: addedByUser)))
        }
        return NSCompoundPredicate.init(andPredicateWithSubpredicates: predicates)
    }
    
}
