//
//  ArticleListCell.swift
//  PommeNews
//
//  Created by Jonathan Duss on 01.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import HTMLString

class ArticleListCell: UITableViewCell {
    
    
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var feedLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet private weak var pictureView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var noImageLeftConstraint: NSLayoutConstraint!
    @IBOutlet var withImageLeftConstraint: NSLayoutConstraint!
    
    private var article: RssArticle?
    private let imageFetcher = Inject.component(ImageFetcher.self)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy - HH:mm"
        return formatter
    }()
    
    //MARK: - Life Cycle
    //==========================================
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let feedImageViewLayer = feedImageView.layer
        feedImageViewLayer.borderColor = UIColor.black.withAlphaComponent(0.6).cgColor
        feedImageViewLayer.borderWidth = 1
        feedImageViewLayer.cornerRadius = feedImageView.frame.height / 4
        
        pictureView.layer.cornerRadius = 5
        pictureView.layer.borderWidth = 1
        pictureView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupForNoImage()
        self.pictureView.image = nil
        self.titleLabel.text = "Loading"
        self.subtitleLabel.text = "Loading"
        feedImageView.image = nil
        feedLabel.text = nil
        dateLabel.text = ""
    }
    
    //MARK: - Action
    //==========================================
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        // Configure the view for the selected state
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Configuration
    //==========================================
    
    func configure(with article: RssArticle) {
        
        
        self.article = article
        
        //Article title, preview and publication date
        self.titleLabel.text = article.title
        self.subtitleLabel.text = article.summary
        dateLabel.text = dateFormatter.string(from: article.date as Date)

        //Feed information
        feedLabel.text = article.feed.name
        feedImageView.image = article.feed.logo
        
        
        //Image
        
        guard let imageUrl = article.imageUrl else {
            self.setupForNoImage()
            return
        }
        
        imageFetcher.fetchImage(at: imageUrl) { image in
            guard article == self.article else {
                //this is not the same article as the one that should be now displayed (concurrency)
                return
            }
            if let image = image {
                DispatchQueue.main.async {
                    self.pictureView.image = image
                    self.pictureView.isHidden = false
                    self.noImageLeftConstraint.isActive = false
                    self.addConstraint(self.withImageLeftConstraint)
                    self.updateConstraints()
                    self.subtitleLabel.layoutIfNeeded()
                }
            }
            else {
                self.setupForNoImage()
            }
        }
    }
    
    private func setupForNoImage() {
        DispatchQueue.main.async {
            self.pictureView.image = nil
            self.pictureView.isHidden = true
            self.withImageLeftConstraint.isActive = false
            self.addConstraint(self.noImageLeftConstraint)
            self.updateConstraints()
            self.subtitleLabel.layoutIfNeeded()
        }
    }
    
    
}
