//
//  Career.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/5/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation
import Firebase

struct Career {

    var name: String
    var code: String


    var dictionary: [String: Any] {
    return [
        "name": name,
        "code": code
        ]
    }
    
    init(name: String,code: String) {
        self.name = name
        self.code = code
    }
    
    var nameFirstLetter: String {
        return String(self.name[self.name.startIndex]).uppercased()
    }
    
    var document: DocumentSnapshot?
}

extension Career {
    
    init?(dictionary: [String : Any]) {
      guard let name = dictionary["name"] as? String,
             let code = dictionary["code"] as? String else { return nil }

        self.init(name: name, code:code)
    }
    
}
