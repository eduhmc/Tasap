//
//  Chat.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/28/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Chat {
    
    var users: [String]
    
    var userGuest: User?

    var dictionary: [String: Any] {
        return ["users": users]
    }
    
}

extension Chat {

    init?(dictionary: [String:Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else {return nil}
        self.init(users: chatUsers)
    }
  
}
