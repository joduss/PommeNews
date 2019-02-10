//
//  PommeNewsConfig.swift
//  PommeNews
//
//  Created by Jonathan Duss on 27.12.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

class PommeNewsConfig {
    public static let GoogleAppId = "ca-app-pub-4180653915602895~3091606580"
    public static var AdUnitBanner: String { get
    {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716" //Test Ads
        #else
        return "ca-app-pub-4180653915602895/9111710711"
        #endif
        }
    }
    
    public static var AdUnitInterstitial: String { get
    {
        #if DEBUG
        return "ca-app-pub-3940256099942544/4411468910" //Test Ads
        #else
        return "ca-app-pub-4180653915602895/7860743184"
        #endif
        }
    }
    
    public static let MinIntervalForBanner: TimeInterval = 30 //TimeInterval(3600 * 24 * 2) // what's the maximum time between 2 display of interstitial
    public static let InterstitialDisplayRequestsThreshold = 2 //after how many request should we really display the interstitial
    
    ///In seconds
    public static let FeedUpdateTimeout = 30
}
