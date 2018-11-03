//
//  ArticleJsonConverter.swift
//  FetchNewArticleToJson
//
//  Created by Jonathan Duss on 28.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

class ArticleJsonConverter {
    
    func convertToJson(articles: [TCArticle]) -> String? {
        let encoder = JSONEncoder()
        
        do {
            let json = try encoder.encode(articles)
            return String(data: json, encoding: String.Encoding.utf8)
        }
        catch {}
        return nil
    }
    
}
