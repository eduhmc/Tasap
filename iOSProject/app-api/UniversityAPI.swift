//
//  UniversityAPI.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 6/1/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
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
        
        let docRef = Firestore.firestore().collectionGroup("universities").whereField("id", isEqualTo: documentID)
                         
        docRef.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
              print("Error fetching snapshot results: \(error!)")
              return
            }
            if snapshot.documents.count > 0 {
                completion(.success(snapshot.documents[0]))
            } else {
                completion(.failure(CrudError(message:"Document does not exist")))
            }
        }
    }
    
    func delete(documentID: String) {
        
    }
    
}
