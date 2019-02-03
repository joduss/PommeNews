//
//  ThemeFiltersPreferences.swift
//  PommeNews
//
//  Created by Jonathan Duss on 03.02.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation
import NSLoggerSwift

class ThemeFiltersPreferences {
    
    private let ThemeFiltersPreferenceKey = "ThemeFiltersPreferenceKey"
    
    private var _filteringThemes: [Theme] = []
    
    private(set) var allThemes: [Theme] = [] //Is more like an utility functions
    
    var onChange: (() -> ())?

    ///The themes the user wants to see
    var filteringThemes: [Theme] {
        set {
            _filteringThemes = newValue
            savePreferences()
        }
        get {
            return _filteringThemes
        }
    }
    
    //MARK: Init
    //==================================================================
    
    init() {
        allThemes = ThemeRequest().execute(context: CoreDataStack.shared.context)
        loadPreviouslySelectedThemes()
        NotificationCenter.default.addObserver(self, selector: #selector(settingChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    //MARK: Data Loading
    //==================================================================
    
    private func loadPreviouslySelectedThemes() {
        if let savedThemesString = UserDefaults.standard.value(forKey: ThemeFiltersPreferenceKey) as? [String] {
            for themeString in savedThemesString {
                if let theme = allThemes.filter({ $0.key == themeString }).first {
                    _filteringThemes.append(theme)
                }
                else {
                    Logger.shared.log(Logger.Domain.app, .important, "Theme not found with key (\(themeString)).")
                }
            }
        }
    }
    
    
    //MARK: Notification handling
    //==================================================================
    
    @objc private func settingChanged(notification: NSNotification) {
        loadPreviouslySelectedThemes()
        onChange?()
    }
    
    //MARK: Saving
    //==================================================================
    
    private func savePreferences() {
        UserDefaults.standard.set(_filteringThemes.map({ $0.key }), forKey: ThemeFiltersPreferenceKey)
    }
  
}
