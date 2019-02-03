//
//  BannerView.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import UIKit
import GoogleMobileAds

public class BannerView: NSObject, GADBannerViewDelegate {
    
    private var bannerView: GADBannerView!
    private let controller: UIViewController
    private let backgroundView: UIView
    private let adId: String
    
    public var tableView: UITableView?
    
    private var view: UIView {
        return controller.view
    }
    
    init(on controller: UIViewController, adId: String) {
        self.controller = controller
        self.adId = adId
        self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    }
    
    func createBannerViewOnBottom() {
        
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.rootViewController = controller
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.isHidden = true
        self.view.addSubview(backgroundView)
        
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        if let visualEffectView = backgroundView as? UIVisualEffectView {
            visualEffectView.contentView.addSubview(bannerView)
        }
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        bannerView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        bannerView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor).isActive = true
        
        
        self.bannerView.delegate = self
        bannerView.adUnitID = adId
        bannerView.load(GADRequest())
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        backgroundView.isHidden = false
        self.adaptTableView()
    }
    
    private func adaptTableView() {
        
        guard let tableview = self.tableView else { return }
        
        let existingInsets = tableview.contentInset
        tableview.contentInset = UIEdgeInsets(top: existingInsets.top,
                                              left: existingInsets.left,
                                              bottom: bannerView.frame.height,
                                              right: existingInsets.right)
        
        let existingIndicatorInsets = tableview.scrollIndicatorInsets
        tableview.scrollIndicatorInsets = UIEdgeInsets(top: existingIndicatorInsets.top,
                                                       left: existingIndicatorInsets.left,
                                                       bottom: bannerView.frame.height,
                                                       right: existingIndicatorInsets.right)
    }
}
