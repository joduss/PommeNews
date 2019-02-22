//
//  ViewControllerAdvertised.swift
//  PommeNews
//
//  Created by Jonathan Duss on 01.01.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import UIKit
import GoogleMobileAds
import os.log

class ViewControllerAdmob: UIViewController {
    
    private let interstitialAdManager = InterstitialAd()
    private var interstitialAd: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitialAd = GADInterstitial(adUnitID: PommeNewsConfig.AdUnitInterstitial)
        interstitialAd.load(GADRequest())
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if interstitialAd.isReady && interstitialAdManager.shouldDisplayAd() {
            interstitialAd.present(fromRootViewController: self)
            interstitialAdManager.displaysAd()
        }
    }
    
}
