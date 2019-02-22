//
//  ArticleForIO.swift
//  FetchNewArticleToJson
//
//  Created by Jonathan Duss on 28.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


public struct TCArticle: Codable, Hashable {
    public let title: String
    public let summary: String
    public let themes: [String]
    
    public init(title: String?, summary: String?, themes: [String] = []) {
        self.title = title ?? ""
        self.summary = summary ?? ""
        self.themes = themes
    }
    
    

}
