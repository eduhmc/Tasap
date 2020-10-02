//
//  HomeTableViewCell.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/2/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    
    func populate(career: Career) {
        self.titleLable.text =  "\(career.name) (\(career.code))"
    }

}
