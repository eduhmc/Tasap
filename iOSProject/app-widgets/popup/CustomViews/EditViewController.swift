//
//  EditViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/26/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit

enum TypeTextField {
    case numeric
    case string
    case password
}


class EditViewController: UIViewController {

    var textTitle = ""
    var textComment = ""
    var typeTextField: TypeTextField = .string
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        titleLabel.text = textTitle
        commentTextField.text = textComment
        
        switch typeTextField {
        case .numeric:
            commentTextField.keyboardType = .numbersAndPunctuation
            break
        case .string:
            commentTextField.keyboardType = .asciiCapable
        case .password:
            commentTextField.isSecureTextEntry = true
            break
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func endEditing() {
        view.endEditing(true)
    }
}

extension EditViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
