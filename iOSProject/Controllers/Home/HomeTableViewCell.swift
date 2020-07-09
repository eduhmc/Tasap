//
//  HomeTableViewCell.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/2/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    
    func populate(career: Career) {
        self.titleLable.text =  "\(career.name) (\(career.code))"
    }

}
