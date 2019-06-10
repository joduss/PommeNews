//
//  Language.swift
//  PommeNews
//
//  Created by Jonathan Duss on 10.03.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation

enum Language: String {
    case french = "fr"
    case english = "en"
    case german = "de"
    
    static func from(_ value: String) -> Language {
        return Language(rawValue: value) ?? .english
    }
    
    func emoji() -> String {
        switch self {
        case .french:
            return "🇫🇷"
        case .english:
            return "🇬🇧"
        case .german:
            return "🇩🇪"
        default:
            return ""
        }
    }
    
    static func system() -> Language {
        return from(Locale.current.languageCode ?? "en")
    }
}
