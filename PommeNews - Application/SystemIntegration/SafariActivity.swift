//
//  SafariActivity.swift
//  PommeNews
//
//  Created by Jonathan Duss on 15.07.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

class SafariActivity: UIActivity {
    
    private var url: URL!
    
    public override var activityType: UIActivityType {
        return UIActivityType("SafariActivity")
    }
    
    public override var activityTitle: String? {
     return "activity.safari".localized
    }

    override var activityImage: UIImage? {
        return #imageLiteral(resourceName: "safari-icon.png")
    }
    
    override class var activityCategory: UIActivityCategory {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        guard activityItems.count == 1 else {
            return false
        }
        
        if activityItems.first is URL  {
            return true
        }
        else if let string = activityItems.first as? String {
            return string.starts(with: "http")
        }
        else {
            return false
        }
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        if let url = activityItems.first as? URL  {
            self.url = url
        }
        else {
            let stringMaybeUrl = activityItems.first as! String
            self.url = URL(string: stringMaybeUrl)
        }
    }
    
    override func perform() {
        UIApplication.shared.open(self.url, options: [:], completionHandler: nil)
    }
    
    
}
