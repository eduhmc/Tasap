//
//  ProfileHamburgerPresenter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/24/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class ProfileHamburgerPresenter: ProfileHamburgerViewToPresenterProtocol {
    
    var view: ProfileHamburgerPresenterToViewProtocol?
    var interactor: ProfileHamburgerPresenterToInteractorProtocol?
    var router: ProfileHamburgerPresenterToRouterProtocol?
    
    var parent: ProfileViewController
    
    init(parent: ProfileViewController) {
        self.parent = parent
    }
       
    func loadData() {
        interactor?.loadData()
    }
    
    func showCalendarModule() {
        router?.pushToCalendarModule(fromView: parent)
    }
    
    func showProfileDetailModule() {
        router?.pushToProfileDetailModule(fromView: parent)
    }
    
    func showCoursesListModule() {
        router?.pushToCoursesListModule(fromView: parent)
    }
    
    func showUpdateCoursesListModule() {
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            
            if userAuth.isTutor {
                router?.pushToUpdateCoursesListModule(fromView: parent)
            }else{
                
                let alert = UIAlertController(title: "Info", message: "In order to be a tutor, please select the courses you want to tutor", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                    self.router?.pushToUpdateCoursesListModule(fromView: self.parent)
                }

                alert.addAction(okAction)

                parent.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
        
    }
    
    func showLoginModule() {
        router?.pushToLoginModule(fromView: parent)
    }
    
}

extension ProfileHamburgerPresenter : ProfileHamburgerInteractorToPresenterProtocol{
    
    func loadedData(model: ProfileHamburgerModel) {
        view?.showData(model: model)
    }
    
}
