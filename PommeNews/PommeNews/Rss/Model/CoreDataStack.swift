//
//  CoreDataStack.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    private(set) var context: NSManagedObjectContext!
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "Database")
        
        self.persistentContainer.loadPersistentStores(completionHandler: { description, error in
            //TODO when error
            print("\(description), ERROR: \(error)")
            self.context = self.persistentContainer.viewContext
            self.context.automaticallyMergesChangesFromParent = true
        })
        
    }
    
    func save() throws {
        try self.context.save()
    }
    
    
    func executeInNewQueueWith<T>(object: T, block: @escaping (T) -> ()) where T:NSManagedObject {
        
        let objectId = object.objectID
        
        DispatchQueue(label: "CoreDataStack" + Date().description).async {
            let backgroundContext = self.persistentContainer.newBackgroundContext()
            
            let objectInBackgroundCtx = backgroundContext.object(with: objectId) as! T
            
            block(objectInBackgroundCtx)
            
            try? backgroundContext.save()
        }
    }
}
