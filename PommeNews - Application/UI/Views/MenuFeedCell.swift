//
//  MenuFeedCell.swift
//  PommeNews
//
//  Created by Jonathan Duss on 06.05.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

class MenuFeedCell: UITableViewCell {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private var cellImageView: UIImageView!
    @IBOutlet private var switchButton: UISwitch!
    override internal var imageView: UIImageView? {
        return cellImageView
    }
    
    private var feed: RssFeed!
    private var mode: StreamManagementMode!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.layer.cornerRadius = 5
        imageView?.layer.borderColor = UIColor.black.cgColor
        imageView?.layer.borderWidth = 1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
    }
    
    func setup(with feed: RssFeed, mode:
        StreamManagementMode){
        
        self.feed = feed;
        self.mode = mode
        
        label.text = feed.name
        imageView?.image = feed.logo
        
        switch mode {
        case .favorite:
            switchButton.isOn = feed.favorite
        case .hidden:
            switchButton.isOn = !feed.hidden
        }
    }
    
    @IBAction func switchClicked(_ sender: UISwitch) {
        switch mode {
        case .favorite:
            feed.favorite = !feed.favorite
        case .hidden:
            feed.hidden = !feed.hidden
        default:
            //if suddenly nil
            return
        }
    }
}
