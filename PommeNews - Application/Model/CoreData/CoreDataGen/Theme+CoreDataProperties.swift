//
//  Theme+CoreDataProperties.swift
//  PommeNews
//
//  Created by Jonathan Duss on 03.11.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//
//

import Foundation
import CoreData


extension Theme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Theme> {
        return NSFetchRequest<Theme>(entityName: "Theme")
    }

    @NSManaged public var key: String
    @NSManaged public var articles: NSSet?

}

// MARK: Generated accessors for articles
extension Theme {

    @objc(addArticlesObject:)
    @NSManaged public func addToArticles(_ value: RssArticle)

    @objc(removeArticlesObject:)
    @NSManaged public func removeFromArticles(_ value: RssArticle)

    @objc(addArticles:)
    @NSManaged public func addToArticles(_ values: NSSet)

    @objc(removeArticles:)
    @NSManaged public func removeFromArticles(_ values: NSSet)

}
