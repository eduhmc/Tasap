//
//  RatingViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/22/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//


import UIKit

class RatingViewController: UIViewController {

    var textSubtitle = ""
    var textComment = ""
    var rateNumber = 0
    
    @IBOutlet weak var cosmosStarRating: CosmosView!

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        subtitleLabel.text = textSubtitle
        commentTextField.text = textComment
        cosmosStarRating.rating = Double(rateNumber)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func endEditing() {
        view.endEditing(true)
    }
}

extension RatingViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
