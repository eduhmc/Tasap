//
//  RequestInteractor.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/27/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RequestInteractor: RequestPresenterToInteractorProtocol{
    
    var presenter: RequestInteractorToPresenterProtocol?

    func loadRequests(state: String, type: String) {
        query = baseQuery(state: state, type: type)
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
            observeQuery()
        }
    }
    
    fileprivate func observeQuery() {
        
        guard let query = query else { return }
        stopObserving()
        
        listener = query.addSnapshotListener {  (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let models = snapshot.documents.map { (document) -> Request in
                
                if var model = Request(dictionary: document.data()) {
                    model.document = document
                    return model
                } else {
                    fatalError("Unable to initialize type \(Request.self) with dictionary \(document.data())")
                }
            }
            self.presenter?.fetchRequests(requests: models)
        }
        
    }
    
    func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery(state: String, type: String) -> Query {
        return AuthenticationManager.shared.currentUser!.document!.collection("requests").whereField("state", isEqualTo: state).whereField("title", isEqualTo: type)
    }
    
    
}
