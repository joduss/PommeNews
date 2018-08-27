//
//  ArticleTheme.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.07.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


struct ArticleTheme: Hashable {
    
    static let iPhone = ArticleTheme(key: "iphone")
    static let iPad = ArticleTheme(key: "ipad")
    static let appleWatch = ArticleTheme(key: "appleWatch")

    static let surface = ArticleTheme(key: "surface")
    
    static let android = ArticleTheme(key: "android")
    static let ios = ArticleTheme(key: "ios")
    static let windows = ArticleTheme(key: "windows")
    static let macos = ArticleTheme(key: "macos")
    
    static let mac = ArticleTheme(key: "mac")
    static let pc = ArticleTheme(key: "pc")
    
    static let computer = ArticleTheme(key: "computer")
    static let smartphone = ArticleTheme(key: "smartphone")
    static let tablet = ArticleTheme(key: "tablet")
    static let watch = ArticleTheme(key: "watch")

    static let apple = ArticleTheme(key: "apple")
    static let microsoft = ArticleTheme(key: "microsoft")
    static let google = ArticleTheme(key: "google")
    static let samsung = ArticleTheme(key: "samsung")
    
    static let other = ArticleTheme(key: "other")

    public static var allThemes: [ArticleTheme] = [ArticleTheme.iPhone,
                           ArticleTheme.iPad,
                           ArticleTheme.appleWatch,
                           ArticleTheme.surface,
                           ArticleTheme.android,
                           ArticleTheme.ios,
                           ArticleTheme.windows,
                           ArticleTheme.macos,
                           ArticleTheme.mac,
                           ArticleTheme.pc,
                           ArticleTheme.computer,
                           ArticleTheme.smartphone,
                           ArticleTheme.tablet,
                           ArticleTheme.watch,
                           ArticleTheme.apple,
                           ArticleTheme.microsoft,
                           ArticleTheme.google,
                           ArticleTheme.samsung,
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
}
