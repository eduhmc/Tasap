//
//  University.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/29/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation
import Firebase

struct University {

    var name: String
    var code: String?
    var domain: String
    var imagePath: String
    
    var dictionary: [String: Any] {
    return [
        "name": name,
        "domain": domain,
        "imagePath": imagePath
        ]
    }
    
    init(name: String, domain: String, imagePath: String) {
        self.name = name
        self.domain = domain
        self.imagePath = imagePath
    }
 
    var document: DocumentSnapshot?

}

extension University {
    
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
               let domain = dictionary["domain"] as? String,
               let imagePath = dictionary["imagePath"] as? String else { return nil }
        self.init(name: name, domain: domain, imagePath: imagePath)
    }
    
}
