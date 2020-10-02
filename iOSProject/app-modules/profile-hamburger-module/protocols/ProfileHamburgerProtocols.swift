//
//  ProfileHamburgerProtocols.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/24/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

protocol ProfileHamburgerViewToPresenterProtocol: class {
    
    var view: ProfileHamburgerPresenterToViewProtocol? {get set}
    var interactor: ProfileHamburgerPresenterToInteractorProtocol? {get set}
    var router: ProfileHamburgerPresenterToRouterProtocol? {get set}
    
    func loadData()
    func showCalendarModule()
    func showProfileDetailModule()
    func showCoursesListModule()
    func showUpdateCoursesListModule()
    func showLoginModule()
}

protocol ProfileHamburgerPresenterToViewProtocol: class {
    func showData(model: ProfileHamburgerModel)
}

protocol ProfileHamburgerPresenterToInteractorProtocol: class {
    var presenter: ProfileHamburgerInteractorToPresenterProtocol? {get set}
    func loadData()
}

protocol ProfileHamburgerInteractorToPresenterProtocol: class {
    func loadedData(model: ProfileHamburgerModel)
}

protocol ProfileHamburgerPresenterToRouterProtocol: class {
    static func createProfileHamburgerModule(view: ProfileHamburgerView, parent: ProfileViewController)
    func pushToCalendarModule(fromView: UIViewController)
    func pushToProfileDetailModule(fromView: UIViewController)
    func pushToCoursesListModule(fromView: UIViewController)
    func pushToUpdateCoursesListModule(fromView: UIViewController)
    func pushToLoginModule(fromView: UIViewController)
}
