//
//  FilterVCCell.swift
//  PommeNews
//
//  Created by Jonathan Duss on 14.10.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

class FilterVCCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconBackgroundView: UIView!
    
    override var isHighlighted: Bool {
        didSet {
                updateColor()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateColor()
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var title: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var iconBackgroundColor: UIColor? {
        get {
            return iconBackgroundColorNormal
        }
        set {
            iconBackgroundColorNormal = newValue
            updateColor()
        }
    }
    
    private var iconBackgroundColorNormal: UIColor?
//    private var iconBackgroundColorHighlighted: UIColor?
//    private var iconBackgroundColorSelected: UIColor?
//    private var iconBackgroundColorSelectedHighlighted: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.iconBackgroundView.layer.borderColor = UIColor.black.cgColor
    }

    override func prepareForReuse() {
        self.title = nil
        self.image = nil
    }
    
    private func updateColor() {
        if isHighlighted {
            self.iconBackgroundView.backgroundColor = iconBackgroundColorNormal?.withBrightnessChange(0.2)
        }
        else {
            self.iconBackgroundView.backgroundColor = iconBackgroundColorNormal
        }
        
        if isSelected {
            self.iconBackgroundView.layer.borderWidth = 3
        }
        else {
            self.iconBackgroundView.layer.borderWidth = 0
        }
    }
}
