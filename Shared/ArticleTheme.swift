//
//  ArticleTheme.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.07.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


struct ArticleTheme: Hashable, Equatable {
    
    static let iPhone = ArticleTheme(key: "iphone")
    static let iPad = ArticleTheme(key: "ipad")
    static let appleWatch = ArticleTheme(key: "appleWatch")
    static let appleTV = ArticleTheme(key: "appleTV")
    static let mac = ArticleTheme(key: "mac")
    static let pc = ArticleTheme(key: "pc")
    
    static let surface = ArticleTheme(key: "surface")
    
    static let android = ArticleTheme(key: "android")
    static let ios = ArticleTheme(key: "ios")
    static let windows = ArticleTheme(key: "windows")
    static let macos = ArticleTheme(key: "macos")
    
    static let apps = ArticleTheme(key: "apps")
    
    static let computer = ArticleTheme(key: "computer")
    static let smartphone = ArticleTheme(key: "smartphone")
    static let tablet = ArticleTheme(key: "tablet")
    static let watch = ArticleTheme(key: "watch")
    
    static let apple = ArticleTheme(key: "apple")
    static let microsoft = ArticleTheme(key: "microsoft")
    static let google = ArticleTheme(key: "google")
    static let samsung = ArticleTheme(key: "samsung")
    static let amazon = ArticleTheme(key: "amazon")

    
    static let rumor = ArticleTheme(key: "rumor")
    static let appleMusic = ArticleTheme(key: "appleMusic")
    static let music = ArticleTheme(key: "music")
    static let icloud = ArticleTheme(key: "icloud")
    
    static let other = ArticleTheme(key: "other")
    
    public static var allThemes: [ArticleTheme] = [
        ArticleTheme.iPhone,
        ArticleTheme.iPad,
        ArticleTheme.appleWatch,
        ArticleTheme.appleTV,
        ArticleTheme.mac,
        ArticleTheme.pc,
        
        ArticleTheme.surface,
        
        ArticleTheme.android,
        ArticleTheme.ios,
        ArticleTheme.windows,
        ArticleTheme.macos,
        
        ArticleTheme.apps,

        ArticleTheme.computer,
        ArticleTheme.smartphone,
        ArticleTheme.tablet,
        ArticleTheme.watch,
        
        ArticleTheme.apple,
        ArticleTheme.microsoft,
        ArticleTheme.google,
        ArticleTheme.samsung,
        ArticleTheme.amazon,
        
        ArticleTheme.rumor,
        ArticleTheme.appleMusic,
        ArticleTheme.music,
        ArticleTheme.icloud,
        
        ArticleTheme.other]
    
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    var localized: String {
        return self.key.localized
    }
    
    func title(forLanguageCode languageCode: String) -> String {
        return Locale.current.localizedString(forLanguageCode: languageCode) ?? "" // TODO
    }
    
    static func == (themeLeft: ArticleTheme, ThemeRight: ArticleTheme) -> Bool {
        return themeLeft.key == ThemeRight.key
    }
    
    static func != (themeLeft: ArticleTheme, ThemeRight: ArticleTheme) -> Bool {
        return themeLeft.key != ThemeRight.key
    }
}
