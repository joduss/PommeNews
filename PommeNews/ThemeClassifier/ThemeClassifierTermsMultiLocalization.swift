//
//  ThemeClassifierTermsLocalization.swift
//  PommeNews
//
//  Created by Jonathan Duss on 24.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation



class ThemeClassifierTermsMultiLocalization {
    
    
    func generateClassifierTerms() -> Dictionary<ArticleTheme, [String]> {
        
        var allTheme = ArticleTheme.allThemes
        
        let otherIdx = allTheme.index(where: {$0.key == "other"})!
        allTheme.remove(at: otherIdx)
        
        var dictionaryTerms = Dictionary<ArticleTheme, [String]>()
        
        for theme in allTheme {
            
            switch theme.key {
            case ArticleTheme.watch.key:
                dictionaryTerms[theme] = ["apple watch", "watch", "wear", "montre", "gear"]
            case ArticleTheme.computer.key:
                dictionaryTerms[theme] = ["ordinateur", "mac", "windows", "computer", "lenovo", "hp", "dell", "macbook", "imac"]
            case ArticleTheme.tablet.key:
                dictionaryTerms[theme] = ["tablet", "ipad", "galaxy note", "tablette"]
            case ArticleTheme.mac.key:
                dictionaryTerms[theme] = ["mac", "macbook", "imac", "mac mini", "mac pro"]
            default:
                dictionaryTerms[theme] = [theme.key]
            }
            
        }
        
        return dictionaryTerms
    }
    
    
    
}
