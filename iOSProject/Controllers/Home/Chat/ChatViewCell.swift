//
//  ChatViewCell.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/30/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit

class ChatViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.makeRounded()
    }

    func setup(chat: Chat){
        
        if let userGuest = chat.userGuest {
            
            let url = URL(string: userGuest.imagePath)
            self.userImageView.kf.setImage(with: url)
            
            self.nameLabel.text = "\(userGuest.first) \(userGuest.last)"
        }
    }

}
