//
//  SupportedThemeFilterLoader.swift
//  PommeNews
//
//  Created by Jonathan Duss on 20.09.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

private struct PlistTheme: Decodable {
    var themeKey: String
}

class SupportedThemeFilterLoader {
    
    static let path = Bundle.main.path(forResource: "Supported_Themes", ofType: ".plist")!
    
    private static var instance: SupportedThemeFilterLoader!
    
    public static var shared: SupportedThemeFilterLoader {
        if instance == nil {
            instance = SupportedThemeFilterLoader()
        }
        return instance
    }
    
    public let supportedThemes: [ArticleTheme]
    
    public init() {
        let decoder = PropertyListDecoder()

        let plistUrl = URL(fileURLWithPath: SupportedThemeFilterLoader.path)
        let data = try! Data(contentsOf: plistUrl)
        
        var format = PropertyListSerialization.PropertyListFormat.binary
        
        let themesKeys = try! decoder.decode([String].self, from: data, format: &format)
        
        supportedThemes = themesKeys.map({ArticleTheme(key: $0)})
    }
    
}
