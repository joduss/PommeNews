//
//  PreviousArticlesJsonLoader.swift
//  FetchNewArticleToJson
//
//  Created by Jonathan Duss on 30.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


class ArticlesJsonFileIO {
    
    private let converter = ArticleJsonConverter()
    

    public func loadArticlesFrom(fileLocation: String) throws -> [ArticleForIO] {
        let fileManager = FileManager.default
        if let jsonData = fileManager.contents(atPath: fileLocation) {
            let decoder = JSONDecoder()
            return try decoder.decode([ArticleForIO].self, from: jsonData)
        }
        else {
            throw NAError.error(message: "Error while getting the data at \(fileLocation)")
        }
    }
    
    public func WriteToFile(articles: [ArticleForIO], at fileLocation: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(articles)
        FileManager.default.createFile(atPath: fileLocation, contents: data, attributes: nil)
    }
}
