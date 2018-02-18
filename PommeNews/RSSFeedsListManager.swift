//
//  RSSFeedsListManager.swift
//  PommeNews
//
//  Created by Jonathan Duss on 29.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


class RSSFeedsListManager {
    
    private let SelectedFeedsKey = "SelectedFeedsKey"
    
    private(set) lazy var availableFeeds: [RSSFeedSite] = {
        let decoder = PropertyListDecoder()
        let plistUrl = Bundle.main.url(forResource: "RSSFeeds", withExtension: "plist")!
        let plistData = try! Data(contentsOf: plistUrl)
        return try! decoder.decode([RSSFeedSite].self, from: plistData)
    }()
    
    private var selectedFeedsIds: Set<String> {
        get {
            return UserDefaults.standard.value(forKey: SelectedFeedsKey) as? Set<String> ?? Set()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SelectedFeedsKey)
        }
    }
    
    var selectedFeeds: [RSSFeedSite] {
        return availableFeeds.filter({selectedFeedsIds.contains($0.id)})
    }
    
    
}
