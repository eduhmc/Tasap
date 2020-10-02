//
//  ReviewTutorCell.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/6/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RequestDetailCell: UITableViewCell {


    @IBOutlet weak var tutorImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var outOfTimeView: UIView!
    @IBOutlet weak var viewColor: UIView!
    
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
        
        outOfTimeView.isHidden = request.endDate > Date()
        
        if request.state == "ACCEPTED" {
            viewColor.backgroundColor = request.endDate > Date() ? UIColor(hexString: "#15D14B") : UIColor(hexString: "#0B516E")
        }
        
        courseLabel.text = request.course
        
        dayLabel.text = request.startDate.format(with: "dd")
        monthLabel.text = request.startDate.format(with: "MMM")
        
        let locale = NSLocale.current
        let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
        if formatter.contains("a") {
            //phone is set to 12 hours
            timeLabel.text = "\(request.startDate.format(with: "HH:mm")) - \(request.endDate.format(with: "HH:mm"))"
        } else {
            //phone is set to 24 hours
            timeLabel.text = "\(request.startDate.format(with: "HH:mm aa")) - \(request.endDate.format(with: "HH:mm aa"))"
        }
        
        
        
    }

}
