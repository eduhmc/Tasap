//
//  Course.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/1/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import Firebase

struct Course {

    var name: String
    var code: String
    
    var dictionary: [String: Any] {
    return [
        "name": name,
        "code": code
        ]
    }
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
    
    var codeClean: String {

        if CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: String(code[code.startIndex]))) {
            return "\(String(code.dropFirst()))\(String(code[code.startIndex]))"
        }else{
            return code
        }
    }
    
    var document: DocumentSnapshot?

}

extension Course {
    
    init?(dictionary: [String : Any]) {
      guard let name = dictionary["name"] as? String,
            let code = dictionary["code"] as? String else { return nil }

        self.init(name: name, code: code)
    }
    
}
