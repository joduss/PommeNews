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
            case ArticleTheme.appleWatch.key:
                dictionaryTerms[theme] = ["apple watch"]
            case ArticleTheme.appleTV.key:
                dictionaryTerms[theme] = ["apple tv"]
            case ArticleTheme.appleWatch.key:
                dictionaryTerms[theme] = ["apple watch"]
            case ArticleTheme.mac.key:
                dictionaryTerms[theme] = ["mac", "macbook", "imac", "mac mini", "mac pro"]
            case ArticleTheme.pc.key:
                dictionaryTerms[theme] = ["surface book", "xps", "yoga", "thinkpad"]
            case ArticleTheme.surface.key:
                dictionaryTerms[theme] = ["microsoft surface", "surface book", "surface pro", "surface go", "surface laptop"]
                
            case ArticleTheme.macos.key:
                dictionaryTerms[theme] = ["macos", "osx", "nextstep"]
                
            case ArticleTheme.apps.key:
                dictionaryTerms[theme] = ["application"]
              
            case ArticleTheme.computer.key:
                dictionaryTerms[theme] = ["ordinateur", "mac", "windows", "computer", "lenovo", "hp", "dell", "macbook", "imac", "laptop", "netbook", "imac", "thinkpad", "xps", "surface book", "microsoft surface", "surface laptop"]
            case ArticleTheme.smartphone.key:
                dictionaryTerms[theme] = ["smartphone", "téléphone portable", "mobile phone", "iphone", "nexus", "galaxy S", "pixel", "phone", "téléphone"]
            case ArticleTheme.watch.key:
                dictionaryTerms[theme] = ["apple watch", "watch", "wear", "montre", "gear"]
            case ArticleTheme.tablet.key:
            dictionaryTerms[theme] = ["tablet", "ipad", "galaxy note", "tablette", "surface pro", "surface go"]

            case ArticleTheme.appleWatch.key:
                dictionaryTerms[theme] = ["rumor", "rumeur"]
            case ArticleTheme.appleMusic.key:
                dictionaryTerms[theme] = ["Apple music"]
            case ArticleTheme.music.key:
                dictionaryTerms[theme] = ["apple music", "streaming", "music", "musique", "chansons", "songs", "spotify", "deezer"]

            default:
                dictionaryTerms[theme] = [theme.key]
            }
            
        }
        
        return dictionaryTerms
    }
    
    
    
}
