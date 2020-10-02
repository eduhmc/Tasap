//
//  ReviewTableViewCell.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/22/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var userimageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewCosmosView: CosmosView!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userimageView.makeRounded()
    }
    
    func populate(review: Review){
        
        let docRef = Firestore.firestore().collection("users").document(review.author)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let user:User! = User(dictionary: document.data()!)
                self.nameLabel.text = user.first
                
                let url = URL(string: user.imagePath)
                self.userimageView.kf.setImage(with: url)
                
            } else {
                print("Document does not exist")
            }
        }
             
        self.commentLabel.text = review.comment
        self.reviewCosmosView.rating =  Double(review.review)
          
    }

}
