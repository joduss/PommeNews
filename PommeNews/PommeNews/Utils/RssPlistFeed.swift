//
//  RssPlistFeed.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

///Feed object parsed from the PList containing all the feeds that are supported
struct RssPlistFeed: Codable {
    
    let name: String
    let url: String
    let id: String
    
    init(name: String, url: String, id: String) {
        self.name = name
        self.url = url
        self.id = id
    }

}
