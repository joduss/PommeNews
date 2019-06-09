//
//  Request.swift
//  PommeNews
//
//  Created by Jonathan Duss on 02.11.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData


public class Request<T> where T: NSManagedObject & EntityName {
    
    private let request: NSFetchRequest<T>
    public let sortOrder: SortOrder
    private var andPredicates: [NSPredicate] = []
    
    convenience init() {
        self.init(sortOrder: .Ascending, sortKey: nil)
    }
    
    init(sortOrder: SortOrder = .Ascending, sortKey: String? = nil) {
        request = NSFetchRequest(entityName: T.entityName)
        if let sortKey = sortKey {
            request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortOrder == .Ascending)]
        }
        self.sortOrder = sortOrder
    }
    
    func and(_ predicate: NSPredicate) {
        andPredicates.append(predicate)
    }
    
    func remove(predicate: NSPredicate) {
        if let idx = andPredicates.firstIndex(of: predicate) {
            self.andPredicates.remove(at: idx)
        }
    }
    
    func fetchRequest() -> NSFetchRequest<T>{
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: andPredicates)
        return request
    }
    
    func update() {
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: andPredicates)
    }
    
    func execute(context: NSManagedObjectContext) -> [T] {
        do {
            return try context.fetch(request)
        }
        catch {
            debugPrint("Error while fetching for type \(T.self): \(error)")
            return []
        }
    }
    
    func execute(context: NSManagedObjectContext, completion: (([T]) -> ())) {
        context.performAndWait {
            do {
                let results = try request.execute()
                completion(results)
            }
            catch {
                debugPrint("Error while fetching for type \(T.self): \(error)")
                completion([])
            }
        }
    }
    
    static func objectWithId(id: NSManagedObjectID, context: NSManagedObjectContext) -> T {
        return context.object(with: id) as! T
    }
}
