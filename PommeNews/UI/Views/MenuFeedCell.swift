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
    
    override internal var imageView: UIImageView? {
        return cellImageView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
    }

    func setup(with feed: RssFeed, mode: StreamManagementMode){
        label.text = feed.name
        
        switch mode {
        case .favorite:
            imageView?.image = feed.favorite ? #imageLiteral(resourceName: "favori") : nil
        case .hidden:
            imageView?.image = feed.hidden ? #imageLiteral(resourceName: "hidden") : nil
        }
    }

}
