//
//  ChatViewCell.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/30/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class ChatViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.makeRounded()
    }

    func setup(chat: Chat, isNoRead: Bool){
        
        if let userGuest = chat.userGuest {
            
            let url = URL(string: userGuest.imagePath)
            self.userImageView.kf.setImage(with: url)
            
            if isNoRead {
                badgeView.clipsToBounds = false
                badgeView.badge(text: "New")
            }else{
                badgeView.clipsToBounds = true
                badgeView.badge(text: nil)
            }
            
            self.nameLabel.text = "\(userGuest.first) \(userGuest.last)"
        }
    }

}
