//
//  ProfileHamburgerPresenter.swift
//  iOSProject
//
//  Created by everis on 8/24/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
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
        router?.pushToUpdateCoursesListModule(fromView: parent)
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
