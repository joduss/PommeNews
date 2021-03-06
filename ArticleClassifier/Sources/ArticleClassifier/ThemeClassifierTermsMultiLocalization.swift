//
//  ThemeClassifierTermsLocalization.swift
//  PommeNews
//
//  Created by Jonathan Duss on 24.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import ArticleClassifierCore


class ThemeClassifierTermsMultiLocalization {
    
    
    func generateClassifierTerms() -> Dictionary<ArticleTheme, [String]> {
        
        var allTheme = ArticleTheme.allThemes
        
        let otherIdx = allTheme.firstIndex(where: {$0.key == "other"})!
        allTheme.remove(at: otherIdx)
        
        var dictionaryTerms = Dictionary<ArticleTheme, [String]>()
        
//        for theme in allTheme {
//            
//            switch theme.key {
//            case ArticleTheme.appleWatch.key:
//                dictionaryTerms[theme] = ["apple watch"]
//            case ArticleTheme.appleTV.key:
//                dictionaryTerms[theme] = ["apple tv", "appletv"]
//            case ArticleTheme.appleWatch.key:
//                dictionaryTerms[theme] = ["apple watch"]
//            case ArticleTheme.mac.key:
//                dictionaryTerms[theme] = ["mac", "macbook", "imac", "mac mini", "mac pro", "portables apple", "apple's computer"]
//            case ArticleTheme.pc.key:
//                dictionaryTerms[theme] = ["surface book", "xps", "yoga", "thinkpad"]
//            case ArticleTheme.surface.key:
//                dictionaryTerms[theme] = ["microsoft surface", "surface book", "surface pro", "surface go", "surface laptop"]
//                
//            case ArticleTheme.macos.key:
//                dictionaryTerms[theme] = ["macos", "osx", "nextstep", "mojave", "macos 10.", "mac os"]
//            case ArticleTheme.ios.key:
//                dictionaryTerms[theme] = ["ios", "siri", "watchos", "ipados", "watch os", "ipad os"]
//                
//            case ArticleTheme.apps.key:
//                dictionaryTerms[theme] = ["application", "apps", "the app", "safari"]
//              
//            case ArticleTheme.computer.key:
//                dictionaryTerms[theme] = ["ordinateur", "mac", "windows", "computer", "lenovo", "hp", "dell", "macbook", "imac", "laptop", "netbook", "imac", "thinkpad", "xps", "surface book", "microsoft surface", "surface laptop", "mac mini", "mac pro", "portables Apple", "ordinateur portable"]
//            case ArticleTheme.smartphone.key:
//                dictionaryTerms[theme] = ["smartphone", "téléphone portable", "mobile phone", "iphone", "nexus", "galaxy S", "pixel", "phone", "téléphone"]
//            case ArticleTheme.watch.key:
//                dictionaryTerms[theme] = ["apple watch", "watch", "wear", "montre", "gear"]
//            case ArticleTheme.tablet.key:
//            dictionaryTerms[theme] = ["tablet", "ipad", "galaxy note", "tablette", "surface pro", "surface go"]
//
//            case ArticleTheme.keynote.key:
//                dictionaryTerms[theme] = ["keynote", "wwdc"]
//                
//            case ArticleTheme.appleWatch.key:
//                dictionaryTerms[theme] = ["rumor", "rumeur", "pourrait"]
//            case ArticleTheme.appleMusic.key:
//                dictionaryTerms[theme] = ["apple music"]
//            case ArticleTheme.music.key:
//                dictionaryTerms[theme] = ["apple music", "streaming", "music", "musique", "chansons", "songs", "spotify", "deezer", "casque", "enceinte", "ue boom", "megaboom", "akg", "sennheiser", "ampli", "airpods", "écouteurs", "homepod", "tidal"]
//
//            case ArticleTheme.apple.key:
//                dictionaryTerms[theme] = ["airPods", "airport", "siri", "apple", "apple music", "ipad", "iphone", "ios", "macos", "osx", "apple TV", "macbook", "mac", "apple watch", "mac mini", "icloud", "watchos", "xcode", "itunes"]
//
//            case ArticleTheme.microsoft.key:
//                dictionaryTerms[theme] = ["microsoft", "microsoft surface", "azure", "surface book", "surface pro", "surface go", "windows 10", "visual studio"]
//                
//            case ArticleTheme.amazon.key:
//                dictionaryTerms[theme] = ["amazon", "aws", "alexa"]
//                
//            case ArticleTheme.apps.key:
//                dictionaryTerms[theme] = ["photoshop", "itunes", "application", "apps"]
//                
//            case ArticleTheme.game.key:
//                dictionaryTerms[theme] = ["game", "jeu"]
//                
//            case ArticleTheme.video.key:
//                dictionaryTerms[theme] = ["netflix", "amazon prime", "youtube", "hulu", "apple tv plus"]
//                
//            case ArticleTheme.spotify.key:
//                dictionaryTerms[theme] = ["spotify"]
//
//            case ArticleTheme.facebook.key:
//                dictionaryTerms[theme] = ["facebook"]
//                
//            case ArticleTheme.netflix.key:
//                dictionaryTerms[theme] = ["netflix"]
//              
//            case ArticleTheme.patent.key:
//                dictionaryTerms[theme] = ["patent", "brevet"]
//
//                
//            default:
//                dictionaryTerms[theme] = [theme.key]
//            }
//            
//        }
        
        return dictionaryTerms
    }
    
    
    
}
