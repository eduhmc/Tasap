//
//  HomeController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/2/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PopupDialog
import Instructions


class HomeController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var universityLabel: UILabel!
    
    // MARK: - Public properties
    public var user: User?
    var coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = self.user{
           
            nameLabel.text = "Hello \(user.first)"
            
            let docRef = Firestore.firestore().collection("universities").document(user.university)
                   
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {

                    let university = University(dictionary: document.data()!)
                    self.universityLabel.text = university?.name
                    
                } else {
                    self.universityLabel.text = ""
                    print("Document does not exist")
                }
            }
        }
    }
    
    @IBAction func tutorButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "careerSegue", sender: nil)
    }
    
    @IBAction func otherButtonTapped(_ sender: Any) {
       performSegue(withIdentifier: "chatSegue", sender: nil)
    }
    
    @IBAction func requestButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "requestSegue", sender: "PENDING")
    }
    
    @IBAction func meetingButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "requestSegue", sender: "ACCEPTED")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "careerSegue" {
            
            let destinationVC = segue.destination as! HomeViewController
            destinationVC.user = self.user
            
        }else if segue.identifier == "requestSegue" {
            
            let destinationVC = segue.destination as! RequestsViewController
            destinationVC.user = self.user
            destinationVC.state = sender as! String
        }
   
    }
    
}