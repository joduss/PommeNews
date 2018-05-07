//
//  RssArticle+CoreDataProperties.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//
//

import Foundation
import CoreData


extension RssArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RssArticle> {
        return NSFetchRequest<RssArticle>(entityName: "RssArticle")
    }

    @NSManaged public var creator: String?
    @NSManaged public var date: NSDate!
    @NSManaged public var feedTypeRaw: Int16
    @NSManaged public var imageUrl: URL?
    @NSManaged public var link: URL!
    @NSManaged public var read: Bool
    @NSManaged public var summary: String?
    @NSManaged public var title: String!
    @NSManaged public var feed: RssFeed!

}
