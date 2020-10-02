//
//  MyCoursesProtocol.swift
//  iOSProject
//
//  Created by everis on 9/21/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

protocol MyCoursesViewToPresenterProtocol: class {
    
    var view: MyCoursesPresenterToViewProtocol? {get set}
    var interactor: MyCoursesPresenterToInteractorProtocol? {get set}
    var router: MyCoursesPresenterToRouterProtocol? {get set}
    
    func loadCourses()
    
}

protocol MyCoursesPresenterToViewProtocol: class {
    func showCourses(courses: [Course])
}

protocol MyCoursesPresenterToInteractorProtocol: class {
    var presenter:MyCoursesInteractorToPresenterProtocol? {get set}
    func fetchCourses()
}

protocol MyCoursesInteractorToPresenterProtocol: class {
    func showCourses(courses: [Course])
}

protocol MyCoursesPresenterToRouterProtocol: class {
    static func createMyCoursesModule(view: MyCoursesView)
}
