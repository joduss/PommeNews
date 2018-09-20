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
                dictionaryTerms[theme] = ["apple tv", "appletv"]
            case ArticleTheme.appleWatch.key:
                dictionaryTerms[theme] = ["apple watch"]
            case ArticleTheme.mac.key:
                dictionaryTerms[theme] = ["mac", "macbook", "imac", "mac mini", "mac pro", "portables apple", "apple's computer"]
            case ArticleTheme.pc.key:
                dictionaryTerms[theme] = ["surface book", "xps", "yoga", "thinkpad"]
            case ArticleTheme.surface.key:
                dictionaryTerms[theme] = ["microsoft surface", "surface book", "surface pro", "surface go", "surface laptop"]
                
            case ArticleTheme.macos.key:
                dictionaryTerms[theme] = ["macos", "osx", "nextstep", "mojave", "macos 10."]
            case ArticleTheme.ios.key:
                dictionaryTerms[theme] = ["ios", "siri", "watchos"]
                
            case ArticleTheme.apps.key:
                dictionaryTerms[theme] = ["application", "apps", "the app", "safari"]
              
            case ArticleTheme.computer.key:
                dictionaryTerms[theme] = ["ordinateur", "mac", "windows", "computer", "lenovo", "hp", "dell", "macbook", "imac", "laptop", "netbook", "imac", "thinkpad", "xps", "surface book", "microsoft surface", "surface laptop", "mac mini", "mac pro", "portables Apple", "ordinateur portable"]
            case ArticleTheme.smartphone.key:
                dictionaryTerms[theme] = ["smartphone", "téléphone portable", "mobile phone", "iphone", "nexus", "galaxy S", "pixel", "phone", "téléphone"]
            case ArticleTheme.watch.key:
                dictionaryTerms[theme] = ["apple watch", "watch", "wear", "montre", "gear"]
            case ArticleTheme.tablet.key:
            dictionaryTerms[theme] = ["tablet", "ipad", "galaxy note", "tablette", "surface pro", "surface go"]

            case ArticleTheme.appleWatch.key:
                dictionaryTerms[theme] = ["rumor", "rumeur", "pourrait"]
            case ArticleTheme.appleMusic.key:
                dictionaryTerms[theme] = ["apple music"]
            case ArticleTheme.music.key:
                dictionaryTerms[theme] = ["apple music", "streaming", "music", "musique", "chansons", "songs", "spotify", "deezer", "casque", "enceinte", "ue boom", "megaboom", "akg", "sennheiser", "ampli", "airpods", "écouteurs", "homepod"]

            case ArticleTheme.apple.key:
                dictionaryTerms[theme] = ["airPods", "airport", "siri", "apple", "apple music", "ipad", "iphone", "ios", "macos", "osx", "apple TV", "macbook", "mac", "apple watch", "mac mini", "icloud", "watchos", "xcode", "itunes"]

            case ArticleTheme.microsoft.key:
                dictionaryTerms[theme] = ["microsoft", "microsoft surface", "azure", "surface book", "surface pro", "surface go", "windows 10", "visual studio"]
                
            case ArticleTheme.apps.key:
                dictionaryTerms[theme] = ["photoshop", "itunes", "application", "apps"]

                
            default:
                dictionaryTerms[theme] = [theme.key]
            }
            
        }
        
        return dictionaryTerms
    }
    
    
    
}
