//
//  HomeTutorTableViewCell.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/9/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class HomeTutorTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var tutorImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var starsView: ImmutableStarsView! {
      didSet {
        starsView.highlightedColor = UIColor(hexString: "#FFD700").cgColor
      }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tutorImageView.makeRounded()
    }
    
    func populate(user: User) {
        
        self.nameLabel.text = "Name: \(user.first) \(user.last)"
        self.descriptionLabel.text = "Description: \(user.description)"
        self.priceLabel.text = "Price: $\(user.price)"
        self.starsView.rating =  Int(user.ratingAverage.rounded())
        
        let url = URL(string: user.imagePath)
        tutorImageView.kf.setImage(with: url)
        
        
        
    }

}
