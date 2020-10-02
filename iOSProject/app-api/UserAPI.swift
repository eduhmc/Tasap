//
//  UserManager.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/30/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


public struct SignupParameters {
    
}


//MARK: Crud Option
protocol UserCrudOption: CrudOption {
    func add(user: User)
}

class UserAPI: UserCrudOption {

    static let shared = UserAPI()

    func add(user: User) {
        
    }
    
    func get(documentID: String, completion: @escaping (Result<DocumentSnapshot,CrudError>) -> ()) {

        let docRef = Firestore.firestore().collection("users").document(documentID)
               
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


//MARK: Authentication

class AuthenticationError: Error {
    
    var message = ""
    
    init(message: String) {
        self.message = message
    }
}

protocol AuthenticationProtocol {
    func login(with credentials: User.Credentials, completion: @escaping (Result<User, AuthenticationError>) -> Void)
    func signup(with parameters: SignupParameters, completion: @escaping (Result<User, AuthenticationError>) -> Void)
    func logout(completion: @escaping (Result<Bool, AuthenticationError>) -> Void)
}

extension UserAPI: AuthenticationProtocol {

    func login(with credentials: User.Credentials, completion: @escaping (Result<User, AuthenticationError>) -> Void) {
        
        Auth.auth().signIn(withEmail: credentials.email, password: credentials.password) { authResult, error in

            if let error = error {
                completion(.failure(AuthenticationError(message: error.localizedDescription)))
            }
            
            guard let userAuth = authResult?.user, error == nil else {
                completion(.failure(AuthenticationError(message: error!.localizedDescription)))
                return
            }
            
            if !userAuth.isEmailVerified {
                completion(.failure(AuthenticationError(message: "Please verify your email before continuing")))
            }else {
                
                let docRef = Firestore.firestore().collection("users").document(userAuth.uid)
                       
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {

                        let user = User(dictionary: document.data()!)

                        if var user = user {
                            user.document = document.reference
                            user.credentials = credentials
                            completion(.success(user))
                        }else{
                            completion(.failure(AuthenticationError(message: "Error parsing Document")))
                        }
                        
                        
                    } else {
                        completion(.failure(AuthenticationError(message: "Document does not exist")))
                    }
                }
                
            }

        }
        
    }
    
    func signup(with parameters: SignupParameters, completion: @escaping (Result<User, AuthenticationError>) -> Void) {
        
    }
    
    func logout(completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion(.success(true))
        } catch let signOutError as NSError {
            completion(.failure(AuthenticationError(message: signOutError.localizedDescription)))
        }
        
    }

}

