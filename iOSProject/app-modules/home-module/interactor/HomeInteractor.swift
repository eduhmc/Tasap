//
//  HomeInteractor.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/11/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import FirebaseFirestore

class HomeInteractor: HomePresenterToInteractorProtocol {
    
    var presenter: HomeInteractorToPresenterProtocol?
    
    func loadInformation() {
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            
            UniversityAPI.shared.get(documentID: userAuth.university) { result in
                switch result {
                    case .success(let document):
                    
                        if let university = University(dictionary: document.data()!){
                            AuthenticationManager.shared.currentUniversity = university
                            let model = HomeModel(university: university)
                            self.presenter?.loadedInformation(model: model)
                        }
                    
                    case .failure(let error):
                        print(error)
                }
            }
            
        }
        
    }
    
    func loadNumberOfRequest() {
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            Firestore.firestore().collection("users").document(userAuth.document!.documentID).collection("requests").whereField("isRead", isEqualTo: false)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(err)
                    } else {
                        
                        var requests: [Request] = []
                        for document in querySnapshot!.documents {
                            let request =  Request(dictionary: document.data())
                            requests.append(request!)
                        }
                        
                        let requestsFiltered = requests.filter { $0.endDate >= Date() }
                        self.presenter?.loadedNumberOfRequest(number: requestsFiltered.count)
                    }
            }
            
        }else {
            print("error")
        }
        
    }
    
    func loadNumberOfChats() {
        
        if let userAuth = AuthenticationManager.shared.currentUser {
        Firestore.firestore().collection("users").document(userAuth.document!.documentID).collection("chats").whereField("count", isGreaterThan: 0)
            .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(err)
                    } else {
                        
                        var chatsNoRead: [String] = []
                        
                        for document in querySnapshot!.documents {
                            chatsNoRead.append(document.reference.documentID)
                        }
                        
                        self.presenter?.loadesNumberOfChats(number: querySnapshot!.documents.count, chatsNoRead: chatsNoRead)
                    }
            }
            
        }else {
            print("error")
        }
        
    }
    
    
    
}
