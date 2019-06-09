//
//  ArticleTheme.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.07.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import ZaJoLibrary

public struct ArticleTheme: Hashable, Equatable {
    
    public static let iPhone = ArticleTheme(key: "iphone")
    public static let iPad = ArticleTheme(key: "ipad")
    public static let appleWatch = ArticleTheme(key: "appleWatch")
    public static let appleTV = ArticleTheme(key: "appleTV")
    public static let mac = ArticleTheme(key: "mac")
    public static let pc = ArticleTheme(key: "pc")
    
    public static let surface = ArticleTheme(key: "surface")
    
    public static let android = ArticleTheme(key: "android")
    public static let ios = ArticleTheme(key: "ios")
    public static let windows = ArticleTheme(key: "windows")
    public static let macos = ArticleTheme(key: "macos")
    
    public static let apps = ArticleTheme(key: "apps")
    public static let game = ArticleTheme(key: "game")

    public static let computer = ArticleTheme(key: "computer")
    public static let smartphone = ArticleTheme(key: "smartphone")
    public static let tablet = ArticleTheme(key: "tablet")
    public static let watch = ArticleTheme(key: "watch")
    
    public static let apple = ArticleTheme(key: "apple")
    public static let microsoft = ArticleTheme(key: "microsoft")
    public static let google = ArticleTheme(key: "google")
    public static let samsung = ArticleTheme(key: "samsung")
    public static let amazon = ArticleTheme(key: "amazon")
    public static let spotify = ArticleTheme(key: "spotify")
    public static let netflix = ArticleTheme(key: "netflix")
    public static let facebook = ArticleTheme(key: "facebook")

    
    public static let rumor = ArticleTheme(key: "rumor")
    public static let appleMusic = ArticleTheme(key: "appleMusic")
    public static let music = ArticleTheme(key: "music")
    public static let video = ArticleTheme(key: "video")
    public static let photo = ArticleTheme(key: "photo")
    public static let icloud = ArticleTheme(key: "icloud")
    
    public static let other = ArticleTheme(key: "other")
    
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
        ArticleTheme.game,

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
        ArticleTheme.video,
        ArticleTheme.photo,
        ArticleTheme.music,
        ArticleTheme.icloud,
        
        ArticleTheme.other]
    
    public let key: String
    
    public init(key: String) {
        self.key = key
    }
    
    public var localized: String {
        return self.key.localized
    }
    
    public func title(forLanguageCode languageCode: String) -> String {
        return Locale.current.localizedString(forLanguageCode: languageCode) ?? "" // TODO
    }
    
    public static func == (themeLeft: ArticleTheme, ThemeRight: ArticleTheme) -> Bool {
        return themeLeft.key == ThemeRight.key
    }
    
    public static func != (themeLeft: ArticleTheme, ThemeRight: ArticleTheme) -> Bool {
        return themeLeft.key != ThemeRight.key
    }
}
