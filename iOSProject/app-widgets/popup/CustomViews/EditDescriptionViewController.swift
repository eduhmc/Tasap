//
//  EditDescriptionViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/28/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit

class EditDescriptionViewController: UIViewController {

    var textTitle = ""
    var textComment = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        titleLabel.text = textTitle
        descriptionTextView.text = textComment
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func endEditing() {
        view.endEditing(true)
    }
}

extension EditDescriptionViewController: UITextViewDelegate {

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        endEditing()
        return true
    }
}
