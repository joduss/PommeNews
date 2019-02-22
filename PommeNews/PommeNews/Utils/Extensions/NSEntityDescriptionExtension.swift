//
//  NSEntityDescriptionExtension.swift
//  PommeNews
//
//  Created by Jonathan Duss on 17.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData


public protocol EntityName {
    
    static var entityName: String { get }
}

extension NSEntityDescription {
    
    static func insertNewObject<T>(into context: NSManagedObjectContext) -> T where T:NSManagedObject, T:EntityName  {
        return NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: context) as! T
    }
    
    
}
