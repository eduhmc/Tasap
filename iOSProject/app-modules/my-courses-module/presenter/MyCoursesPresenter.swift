//
//  MyCoursesPresenter.swift
//  iOSProject
//
//  Created by everis on 9/21/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

class MyCoursesPresenter: MyCoursesViewToPresenterProtocol {
    
    var view: MyCoursesPresenterToViewProtocol?
    var interactor: MyCoursesPresenterToInteractorProtocol?
    var router: MyCoursesPresenterToRouterProtocol?
    
    func loadCourses() {
        interactor?.fetchCourses()
    }
    
}

extension MyCoursesPresenter: MyCoursesInteractorToPresenterProtocol {
    func showCourses(courses: [Course]) {
        view?.showCourses(courses: courses)
    }
}

