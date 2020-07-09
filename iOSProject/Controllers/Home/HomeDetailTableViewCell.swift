//
//  HomeDetailTableViewCell.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/5/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit

class HomeDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    
    func populate(career: Career, course: Course) {
        self.nameLabel.text = course.name
        self.codeLabel.text = "\(career.code) \(course.code)"
    }
    
}
