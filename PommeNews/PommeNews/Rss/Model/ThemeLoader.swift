//
//  ThemeLoader.swift
//  PommeNews
//
//  Created by Jonathan Duss on 23.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData
import ArticleClassifierCore

/// Initial Theme Loader
/// Linked to CoreData
class ThemeLoader {
    
    private var onlySupportedThemes = false
    init(onlySupportedThemes: Bool = true) {
        self.onlySupportedThemes = onlySupportedThemes
    }
    
    //Will load the themes into CoreData
    func loadThemes() throws {
        
        //TODO: load the theme from the supported themes.plist!!!
        
        //Remote not supported themes
        
        //Relaunch classification if new themes are available
        
        
        var themes: [ArticleTheme] = []
        
        if onlySupportedThemes == true {
            themes = SupportedThemeFilterLoader().supportedThemes
        }
        else {
            themes = ArticleTheme.allThemes
        }
        
        for theme in themes {
            if themeExist(theme) ==  false {
                insert(theme: theme)
            }
        }
        
        do {
            try CoreDataStack.shared.save()
        }
        catch {
            throw PError.dbIssue("error.theme.save".localized)
        }
    }
    
    private func themeExist(_ theme: ArticleTheme) -> Bool {
        let request = ThemeRequest().fetchRequest()
        request.predicate = NSPredicate(format: "\(Theme.keyPropertyName)==%@", theme.key)
        
        do {
            return try CoreDataStack.shared.context.count(for: request) != 0
        } catch {
            return false
        }
    }
    
    private func insert(theme: ArticleTheme) {
        let newTheme = NSEntityDescription.insertNewObject(forEntityName: Theme.entityName, into: CoreDataStack.shared.context) as! Theme
        newTheme.key = theme.key
    }
}
