//
//  RegisterDetailViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/17/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import PopupDialog

class RegisterDetailViewController: UIViewController {
    
    @IBOutlet weak var priceLabel: UITextField! {
        didSet {
            self.priceLabel.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var user: User?
    var isChangePhoto: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.descriptionLabel.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        // Do any additional setup after loading the view.
    }
    
    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func careerButtonTapped(_ sender: Any) {
        
        var price = "", description = ""
        
        if priceLabel.text!.count > 0 {
            price = priceLabel.text!
        }else {
            popupShow(message: "Please complete Price")
        }
        
        if descriptionLabel.text.count > 0 {
            description = descriptionLabel.text
        }else {
            popupShow(message: "Please complete Description")
        }
        
        if price != "" && description != "" {
            user?.price = price
            user?.description = description
            self.performSegue(withIdentifier: "tutorSegue", sender: user)
        }
        
    }
    
    func popupShow(message: String){
        
        let popup =  PopupDialog(title: "Error", message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let user = sender as! User
        
        if segue.identifier == "tutorSegue" {
            
            let destinationVC = segue.destination as! RegisterTutorViewController
            destinationVC.user = user
            destinationVC.isChangePhoto = self.isChangePhoto
            
        }
    }
    
}

extension RegisterDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

extension RegisterDetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        topConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        topConstraint.constant = 35
        self.view.layoutIfNeeded()
    }
    
}
