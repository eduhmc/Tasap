//
//  RequestDateCell.swift
//  iOSProject
//
//  Created by Roger Arroyo on 7/24/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setup(date: Date){
        
        monthLabel.text = date.format(with: "MMM")
        dateLabel.text = date.format(with: "EEEE d, yyyy")
        
    }

}
