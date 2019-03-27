//
//  RssFeed+CoreDataProperties.swift
//  PommeNews
//
//  Created by Jonathan Duss on 03.11.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//
//

import Foundation
import CoreData


extension RssFeed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RssFeed> {
        return NSFetchRequest<RssFeed>(entityName: "RssFeed")
    }

    @NSManaged public var favorite: Bool
    @NSManaged public var addedByUser: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var language: String
    @NSManaged public var url: URL
    @NSManaged public var articles: NSSet?

}

// MARK: Generated accessors for articles
extension RssFeed {

    @objc(addArticlesObject:)
    @NSManaged public func addToArticles(_ value: RssArticle)

    @objc(removeArticlesObject:)
    @NSManaged public func removeFromArticles(_ value: RssArticle)

    @objc(addArticles:)
    @NSManaged public func addToArticles(_ values: NSSet)

    @objc(removeArticles:)
    @NSManaged public func removeFromArticles(_ values: NSSet)

}
