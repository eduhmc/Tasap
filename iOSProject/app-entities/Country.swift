//
//  Country.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/10/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import Firebase

struct Country {

    var name: String

    var dictionary: [String: Any] {
    return [
        "name": name
        ]
    }
    
    init(name: String) {
        self.name = name
    }
    
    var nameFirstLetter: String {
        return String(self.name[self.name.startIndex]).uppercased()
    }
    
    var document: DocumentSnapshot?
}

extension Country {
    
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String else { return nil }
        self.init(name: name)
    }
    
}
