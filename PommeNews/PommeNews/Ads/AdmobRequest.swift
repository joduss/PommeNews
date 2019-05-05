//
//  AdmobRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 05.05.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PersonalizedAdConsent


/// Provide functionality to creates GADRequests
/// taking into account the european law: must ask the user if
/// he allows personalized ads.
class AdmobRequest {
    
    private var cachedConsent = PACConsentStatus.unknown
    private var viewController: UIViewController
    
    /// Constructor
    ///
    /// - Parameter viewController: The view controller on which the request popup should be displayed
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    
    /// Creates the GADRequest and is it charge of requesting the user
    /// if he allows personalized ads.
    ///
    /// - Parameter completion: (GADRequest) -> ()
    public func createGADRequest(completion: @escaping (GADRequest) -> ()) {
        guard cachedConsent != .unknown else {
            // We load the consent
            loadConsent {
                if self.cachedConsent != .unknown {
                    // consent loaded. It is ok, we can try again to create the ad request.
                    self.createGADRequest(completion: completion)
                }
                else {
                    // The consent has never been requested. Time to do it now.
                    self.requestConsent {
                        // The consent has been requested. Now let's create this request.
                        self.createGADRequest(completion: completion)
                    }
                }
            }
            return
        }
        
        let request = GADRequest()
        let extras = GADExtras()
        if self.cachedConsent == .nonPersonalized {
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        completion(request)
    }
    
    
    /// Load the consent from somewhere.
    ///
    /// - Parameter completion: () -> () called when the consent has been retrieved from somewhere
    private func loadConsent(completion: @escaping () -> ()) {
        PACConsentInformation.sharedInstance
            .requestConsentInfoUpdate(
                forPublisherIdentifiers: ["pub-4180653915602895"])
            {(_ error: Error?) -> Void in
                if error != nil {
                    // Consent info update failed.
                    self.cachedConsent = .nonPersonalized // We don't know. We just use the least intrusive.
                } else {
                    // Consent info update succeeded. The shared PACConsentInformation instance has been updated.
                    self.cachedConsent = PACConsentInformation.sharedInstance.consentStatus
                }
                completion()
        }
    }
    
    
    /// Request the user's consent for personalized ads.
    ///
    /// - Parameter completion: () -> () called once the user chose if the allows or not.
    private func requestConsent(completion: @escaping () -> ()) {
        guard let privacyUrl = URL(string: "http://todo.com"),
            let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                print("incorrect privacy URL.")
                self.cachedConsent = .nonPersonalized
                completion()
                return
        }
        
        form.shouldOfferPersonalizedAds = true
        form.shouldOfferNonPersonalizedAds = true
        form.shouldOfferAdFree = false
        
        form.load {(_ error: Error?) -> Void in
            print("Load complete.")
            if let error = error {
                // Handle error.
                print("Error loading form: \(error.localizedDescription)")
                self.cachedConsent = .nonPersonalized
                completion()
            } else {
                // Load successful.
                DispatchQueue.main.async {
                    form.present(from: self.viewController) { (error, userPrefersAdFree) in
                        if (error != nil) {
                            self.cachedConsent = .nonPersonalized
                        }
                        else {
                            self.cachedConsent = PACConsentInformation.sharedInstance.consentStatus
                        }
                        completion()
                    }
                }
            }
        }
    }
}
