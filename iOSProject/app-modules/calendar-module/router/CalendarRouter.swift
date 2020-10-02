//
//  CalendarRouter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/4/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

class CalendarRouter: CalendarPresenterToRouterProtocol {
    
    static func createCalendarModule(view: CalendarView, model: CalendarModel) {
        
        let presenter = CalendarPresenter()
        presenter.model = model
        view.presenter = presenter
        view.presenter?.view = view
        view.presenter?.router = CalendarRouter()
        view.presenter?.interactor = CalendarInteractor()
        view.presenter?.interactor?.presenter = presenter
        
    }
 
}
