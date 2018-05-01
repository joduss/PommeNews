//
//  Inject.swift
//  PommeNews
//
//  Created by Jonathan Duss on 19.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import Swinject


class Inject {
    
    
    static let container = Container()
    
    
    class func setup(withFakeServices: Bool = false) -> Inject {
        
        container.register(RSSClient.self, factory: { _ in
            if withFakeServices {
                return FakeRSSClient()
            }
            else {
                return RSSClient()
            }
        }).inObjectScope(.container)
        
        container.register(RSSManager.self, factory: { r in
            return RSSManager(rssClient: r.resolve(RSSClient.self)!)
        }).inObjectScope(.container)
        
        
        
        return Inject()
    }
    
    class func component<T>(_ ofType: T.Type) -> T {
        return container.resolve(ofType)!
    }
    
}
