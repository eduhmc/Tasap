//
//  MyCoursesListProtocol.swift
//  iOSProject
//
//  Created by everis on 9/21/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation

protocol MyCoursesListViewToPresenterProtocol: class {
    
    var view: MyCoursesListPresenterToViewProtocol? {get set}
    var interactor: MyCoursesListPresenterToInteractorProtocol? {get set}
    var router: MyCoursesListPresenterToRouterProtocol? {get set}
    
    func loadCourses()
    
}

protocol MyCoursesListPresenterToViewProtocol: class {
    func showCourses(courses: [Course])
}

protocol MyCoursesListPresenterToInteractorProtocol: class {
    var presenter:MyCoursesListInteractorToPresenterProtocol? {get set}
    func fetchCourses()
}

protocol MyCoursesListInteractorToPresenterProtocol: class {
    func showCourses(courses: [Course])
}

protocol MyCoursesListPresenterToRouterProtocol: class {
    static func createMyCoursesModule(view: CalendarView, model: CalendarModel)
}
