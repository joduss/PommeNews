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

class ViewControllerAdmob: UIViewController, GADInterstitialDelegate {
    
    private let interstitialAdManager = InterstitialAd()
    private var interstitialAd: GADInterstitial!
    private var requestLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitialAd = GADInterstitial(adUnitID: PommeNewsConfig.AdUnitInterstitial)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if requestLoaded == false {
            AdmobRequest(viewController: self).createGADRequest(completion: { request in
                self.interstitialAd.load(GADRequest())
            })
            requestLoaded = true
        }
        
        if self.interstitialAdManager.shouldDisplayAd() && self.interstitialAd.isReady  {
            self.interstitialAd.present(fromRootViewController: self)
            self.interstitialAdManager.displaysAd()
        }
    }
}
