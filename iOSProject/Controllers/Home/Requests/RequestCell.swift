//
//  ReviewTutorCell.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/6/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RequestCell: UITableViewCell {


    @IBOutlet weak var tutorImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    var tutor:User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tutorImageView.makeRounded()
    }
    
    func setup(request: Request){
        
        if let userAuth = AuthenticationManager.shared.currentUser , userAuth.document?.documentID == request.userID {
            
            self.nameLabel.text = "\(userAuth.first) \(userAuth.last)"
            
            let url = URL(string: userAuth.imagePath)
            self.tutorImageView.kf.setImage(with: url)

        }else{
           
            Firestore.firestore().collection("users").document(request.userID).getDocument { (document, error) in
                if let document = document, document.exists {
                    if let tutor = User(dictionary: document.data()!) {
                         
                        self.tutor = tutor
                        self.nameLabel.text =  "\(tutor.first) \(tutor.last)"
          
                        let url = URL(string: tutor.imagePath)
                        self.tutorImageView.kf.setImage(with: url)
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
        }
        
        courseLabel.text = request.course
        
        dayLabel.text = request.startDate.format(with: "dd")
        monthLabel.text = request.startDate.format(with: "MMM")
        timeLabel.text = "\(request.startDate.format(with: "HH:mm aa")) - \(request.endDate.format(with: "HH:mm aa"))"
        
    }

}
