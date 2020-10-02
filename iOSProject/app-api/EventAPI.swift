//
//  Event.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/5/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol EventCrudOption {
    
    func add(user: User, event: Eveent, completion: @escaping (Result<String, CrudError>) -> ())
    func get(user: User, documentID: String, completion: @escaping (Result<DocumentSnapshot, CrudError>) -> ())
    
}

struct EventAPI: EventCrudOption {
    
    static let shared = EventAPI()
    
    func add(user: User, event: Eveent, completion: @escaping (Result<String, CrudError>) -> ()) {
        
        var ref: DocumentReference? = nil
        ref = user.document!.collection("events").addDocument(data: event.dictionary)  { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(.failure(CrudError(message:"Error adding document: \(err)")))
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(.success(ref!.documentID))
            }
        }
    }
    
    func get(user: User, documentID: String, completion: @escaping (Result<DocumentSnapshot, CrudError>) -> ()) {
        
        let docRef = user.document!.collection("events").document(documentID)
               
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
