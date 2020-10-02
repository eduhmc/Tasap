//
//  MyCoursesRouter.swift
//  iOSProject
//
//  Created by everis on 9/21/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

class MyCoursesRouter: MyCoursesPresenterToRouterProtocol {
    
    static func createMyCoursesModule(view: MyCoursesView) {
        
        let presenter = MyCoursesPresenter()
        view.presenter = presenter
        view.presenter?.view = view
        view.presenter?.router = MyCoursesRouter()
        view.presenter?.interactor = MyCoursesInteractor()
        view.presenter?.interactor?.presenter = presenter
        
    }
    
}
