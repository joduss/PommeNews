//
//  InterstitialAd.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.12.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

class InterstitialAd {
    
    private static let LastInterstitialDateKey = "LastInterstitialDateKey"
    
    private var lastInterstitialDate: Date {
        get {
            return UserDefaults.standard.object(forKey: InterstitialAd.LastInterstitialDateKey) as? Date ?? Date.init(timeIntervalSinceReferenceDate: 0)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: InterstitialAd.LastInterstitialDateKey)
        }
    }
    
    private static let LastInterstitialRequestsCountKey = "LastInterstitialRequestsCountKey"
    
    private var lastInterstitialRequestsCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: InterstitialAd.LastInterstitialRequestsCountKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: InterstitialAd.LastInterstitialRequestsCountKey)
        }
    }
    
    public func shouldDisplayAd() -> Bool {
        let lastInterstitialTimeInterval = lastInterstitialDate.timeIntervalSinceReferenceDate
        let currentTimeInterval = Date().timeIntervalSinceReferenceDate
        
        lastInterstitialRequestsCount += 1
        
        guard currentTimeInterval - lastInterstitialTimeInterval > PommeNewsConfig.MinIntervalForBanner else {
            
            return false
        }
        
        return lastInterstitialRequestsCount > PommeNewsConfig.InterstitialDisplayRequestsThreshold
    }
    
    public func displaysAd() {
        lastInterstitialRequestsCount = 0
        lastInterstitialDate = Date()
    }
}
