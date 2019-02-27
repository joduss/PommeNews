//
//  RssPlistFeed.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

///Feed object parsed from the PList containing all the feeds that are supported
public struct RssPlistFeed: Codable {
    
    public let name: String
    public let url: String
    public let id: String
    
    public init(name: String, url: String, id: String) {
        self.name = name
        self.url = url
        self.id = id
    }

}
