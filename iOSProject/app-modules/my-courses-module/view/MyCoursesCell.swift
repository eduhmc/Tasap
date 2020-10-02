//
//  MyCoursesCell.swift
//  iOSProject
//
//  Created by everis on 9/21/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MyCoursesCell: UITableViewCell {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var careerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(course: Course){
        courseNameLabel.text = course.code
        careerNameLabel.text = course.name
    }

}
