//
//  MenuCell.swift
//  PommeNews
//
//  Created by Jonathan Duss on 08.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit


class MenuCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    @IBOutlet weak var unreadLabelBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        self.textLabel?.textColor = UIColor.white
        
        //Configure view behind unread-label
        let unreadLayer = unreadLabelBackground.layer
        unreadLayer.cornerRadius = unreadLayer.frame.height / 2
        unreadLayer.borderWidth = 2
        unreadLayer.borderColor = UIColor.white.cgColor
        
        //Configure icon image view
        let iconLayer = iconImageView.layer
        iconLayer.cornerRadius = 10
        iconLayer.borderWidth = 2
        iconLayer.borderColor = UIColor.black.cgColor
    }
    
    func setup(with feed: RssFeed, numberUnreadArticles: Int) {
        self.titleLabel.text = feed.name
        self.iconImageView.image = feed.logo
        
        self.unreadLabel.isHidden = (numberUnreadArticles < 0)
        self.unreadLabelBackground.isHidden = (numberUnreadArticles < 0)
        self.unreadLabel.text = "\(numberUnreadArticles > 999 ? 999 : numberUnreadArticles)"
        
    }
    
    func setup(with title: String) {
        self.titleLabel.text = title
        self.unreadLabel.isHidden = true
        self.unreadLabelBackground.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = nil
        self.titleLabel.text = nil
        self.unreadLabel.text = nil
        self.unreadLabelBackground.isHidden = true
        self.unreadLabel.isHidden = true
    }
    
}
