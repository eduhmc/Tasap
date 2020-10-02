//
//  MyCoursesInteractor.swift
//  iOSProject
//
//  Created by everis on 9/21/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import FirebaseFirestore


class MyCoursesInteractor: MyCoursesPresenterToInteractorProtocol {
    
    var presenter: MyCoursesInteractorToPresenterProtocol?
    
    func fetchCourses() {
         query = baseQuery()
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
            
            let models = snapshot.documents.map { (document) -> Course in
                
                if var model = Course(dictionary: document.data()) {
                    model.document = document
                    return model
                } else {
                    fatalError("Unable to initialize type \(Request.self) with dictionary \(document.data())")
                }
            }
            self.presenter?.showCourses(courses: models)
        }
        
    }
    
    func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        
        let coursesUserAuth = AuthenticationManager.shared.currentUser!.courses
        return Firestore.firestore().collectionGroup("courses").whereField("id", in: coursesUserAuth)
    }
}
