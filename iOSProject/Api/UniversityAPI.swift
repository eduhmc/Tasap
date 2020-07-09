//
//  UniversityAPI.swift
//  iOSProject
//
//  Created by Roger Arroyo on 6/1/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol UniversityCrudOption: CrudOption {
    func add(university: University)
}

struct UniversityAPI: UniversityCrudOption {
    
    static let shared = UniversityAPI()
    
    func add(university: University) {
        
    }
    
    func get(documentID: String, completion: @escaping (Result<DocumentSnapshot, CrudError>) -> ()) {
        
        let docRef = Firestore.firestore().collection("universities").document(documentID)
                         
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(.success(document))
            } else {
                completion(.failure(CrudError(message:"Document does not exist")))
            }
        }
    }
    
    func delete(documentID: String) {
        
    }
    
    
}
