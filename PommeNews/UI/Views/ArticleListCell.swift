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

    
    @IBOutlet private weak var pictureView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private var article: RssArticle?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with article: RssArticle) {
        
        self.article = article
        
        self.titleLabel.text = article.title
        self.subtitleLabel.text = article.summary

        //todo: image
        
        var imageUrlToDownload: URL?
        
        if let imageUrl = article.imageURL{
            imageUrlToDownload = imageUrl
        }
        else if let imageUrl = article.extractImageUrlFromSummary() {
            imageUrlToDownload = imageUrl
        }
        
        guard let imageUrl = imageUrlToDownload else { return }
        
        DispatchQueue.global().async {
            do {
            let data = try Data(contentsOf: imageUrl)
            if let image = UIImage(data: data), article.link == self.article?.link {
                DispatchQueue.main.async {
                    self.pictureView.image = image
                }
            }
            }
            catch {
                print(error)
            }
        }
        
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.pictureView.image = nil
        self.titleLabel.text = "Loading"
        self.subtitleLabel.text = "Loading"
        
        
        
        let tv = UITextView()
        
        
    }

}
