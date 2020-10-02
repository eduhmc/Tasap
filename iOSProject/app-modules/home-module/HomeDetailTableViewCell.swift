//
//  HomeDetailTableViewCell.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/5/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
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
