//
//  AuthenticationManager.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 6/3/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol AuthenticationManagerProtocol: class , AuthenticationProtocol{
    var currentUser: User? { get set }
}

class AuthenticationManager: AuthenticationManagerProtocol {

    static let shared = AuthenticationManager()
    
    var currentUser: User? {
        didSet {
            
            if let currentUser = currentUser {
                
                if let credentials = currentUser.credentials {
                    let ud = UserDefaults.standard
                    let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials.dictionary, requiringSecureCoding: true)
                    ud.set(data, forKey: "currentUser")
                }
            }
        }
    }
    
    var currentUniversity: University? 
    
    private let userAPI = UserAPI()
    
    func login(with credentials: User.Credentials, completion: @escaping (Result<User, AuthenticationError>) -> Void) {
        
        userAPI.login(with: credentials){ [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                guard let strongSelf = self else {
                    return
                }

                strongSelf.currentUser = user
                completion(.success(user))
                
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
        
        
    }
    
    func signup(with parameters: SignupParameters, completion: @escaping (Result<User, AuthenticationError>) -> Void) {
        
    }
    
    func logout(completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        
        userAPI.logout() { result in
            
            switch result {
            case .success(let bool):
                completion(.success(bool))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
