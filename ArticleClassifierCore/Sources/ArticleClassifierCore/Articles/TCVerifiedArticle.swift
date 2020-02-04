//
//  File.swift
//  
//
//  Created by Jonathan Duss on 26.01.20.
//

import Foundation

public struct TCVerifiedArticle: Codable, Hashable {
    
    public let title: String
    public let summary: String
    public var themes: [String]
    public var verifiedThemes: [String] = []
    public var predictedThemes: [String] = []
    
    private enum CodingKeys: String, CodingKey {
        case title
        case summary
        case themes
        case verifiedThemes
        case predictedThemes
    }
    
    public init(title: String?, summary: String?, themes: [String] = []) {
        self.title = title ?? ""
        self.summary = summary ?? ""
        self.themes = themes
    }
    
    public mutating func verify(theme: String) {
        guard verifiedThemes.contains(theme) == false else { return }
        
        verifiedThemes.append(theme)
    }
    
    public static func == (lhs: TCVerifiedArticle, rhs: TCVerifiedArticle) -> Bool {
        return (lhs.title + lhs.summary).hashValue == (rhs.title + rhs.summary).hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title + summary)
    }
}
