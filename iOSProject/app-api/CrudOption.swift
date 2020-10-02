//
//  CrudOption.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/30/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol CrudOption {
    func get(documentID: String, completion: @escaping (Result<DocumentSnapshot,CrudError>) -> () )
    func delete(documentID: String)
}


//MARK: Error

class CrudError: Error {
    
    var message = ""
    
    init(message: String) {
        self.message = message
    }
    
}
