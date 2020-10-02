//
//  ProfileHamburgerInteractor.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/24/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

class ProfileHamburgerInteractor: ProfileHamburgerPresenterToInteractorProtocol  {
    
    var presenter: ProfileHamburgerInteractorToPresenterProtocol?
    
    func loadData() {
       
        if let userAuth = AuthenticationManager.shared.currentUser {
            let model = ProfileHamburgerModel(userAuth: userAuth)
            presenter?.loadedData(model: model)
        }
        
    }
    
    
}
