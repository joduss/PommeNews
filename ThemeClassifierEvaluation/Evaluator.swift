//
//  Evaluator.swift
//  PommeNews
//
//  Created by Jonathan Duss on 04.09.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


class Evaluator {
    
    private let articlesIO = ArticlesJsonFileIO()
    
    public func startEvaluation(articleLocation: String) {
        let articles = articlesIO.loadArticlesFrom(fileLocation: articleLocation)
    }
    
    
}
