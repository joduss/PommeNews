//
//  File.swift
//  
//
//  Created by Jonathan Duss on 26.01.20.
//

import Foundation


public class TCVerifiedArticle: Codable, Hashable {
    
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
    
    public func verify(theme: String) {
        guard verifiedThemes.contains(theme) == false else { return }
        
        verifiedThemes.append(theme)
    }
    
    public static func == (lhs: TCVerifiedArticle, rhs: TCVerifiedArticle) -> Bool {
        return lhs.title == rhs.title && lhs.summary == rhs.title
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(summary)
    }
    
    public var hashValue: Int {
        var hasher = Hasher()
        hash(into: &hasher)
        return hasher.finalize()
    }
    
    public var titleSummaryHash: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(summary)
        return hasher.finalize()
    }
}
