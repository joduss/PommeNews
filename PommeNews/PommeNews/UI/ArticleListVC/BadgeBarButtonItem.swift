//
//  BadgeBarButtonItem.swift
//  PommeNews
//
//  Created by Jonathan Duss on 10.02.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import UIKit

public class BadgeBarButtonItem: UIBarButtonItem {
    
    private let badgeView = UIView()
    public let badgeLabel = UILabel()
    
    public var badgeRadius: CGFloat = 15
    public var badgeNumber: Int = 1 {
        didSet {
            badgeView.isHidden = badgeNumber == 0 ? true : false
            badgeLabel.text = "\(badgeNumber)"
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        guard let image = image else {
            fatalError("You must provide an image!")
        }
        
        //The container view
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.customView = view

        view.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: image.size.height).isActive = true
        
        //The button containing the image icon
        let button = UIButton()
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        
        if let action = self.action {
            button.addTarget(self.target, action: action, for: UIControl.Event.allEvents)
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        button.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: image.size.height).isActive = true
        
        //The badge
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(badgeView)

        badgeView.heightAnchor.constraint(equalToConstant: badgeRadius).isActive = true
        badgeView.widthAnchor.constraint(equalToConstant: badgeRadius).isActive = true
        badgeView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 2.5).isActive = true
        badgeView.isUserInteractionEnabled = false
        
        badgeView.layer.cornerRadius = badgeRadius / 2.0
        badgeView.backgroundColor = UIColor.black
        
        //Text in badge
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeView.addSubview(badgeLabel)
        
        badgeLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor).isActive = true
        badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor).isActive = true
        badgeLabel.heightAnchor.constraint(equalTo: badgeView.heightAnchor, multiplier: 0.91).isActive = true
        badgeLabel.widthAnchor.constraint(equalTo: badgeView.widthAnchor, multiplier: 0.91).isActive = true

        badgeLabel.textColor = UIColor.white
        badgeLabel.font = UIFont.boldSystemFont(ofSize:12)
        badgeLabel.allowsDefaultTighteningForTruncation = true
        badgeLabel.adjustsFontSizeToFitWidth = true
        badgeLabel.minimumScaleFactor = 0.1
        badgeLabel.textAlignment = .center
        badgeNumber = badgeNumber + 0
    }
    
}
