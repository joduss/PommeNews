//
//  ArticleForIO.swift
//  FetchNewArticleToJson
//
//  Created by Jonathan Duss on 28.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


struct ArticleForIO: Codable {
    let title: String
    let summary: String
    let themes: [String]
    
    init(title: String, summary: String, themes: [String] = []) {
        self.title = title
        self.summary = summary
        self.themes = themes
    }
    

}
