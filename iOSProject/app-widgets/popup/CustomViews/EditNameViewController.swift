//
//  EditNameViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/30/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit


class EditNameViewController: UIViewController {

    var firstName = ""
    var lastName = ""
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
     override func viewDidLoad() {
            super.viewDidLoad()

        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func endEditing() {
        view.endEditing(true)
    }
}

extension EditNameViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
