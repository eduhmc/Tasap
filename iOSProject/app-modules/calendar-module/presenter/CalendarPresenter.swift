//
//  CalendarPresenter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/4/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

class CalendarPresenter: CalendarViewToPresenterProtocol {
    
    var view: CalendarPresenterToViewProtocol?
    var interactor: CalendarPresenterToInteractorProtocol?
    var router: CalendarPresenterToRouterProtocol?
    
    var model: CalendarModel?
    
    func loadEvents() {
        view?.showEvents(model: model!)
    }
    
}

extension CalendarPresenter: CalendarInteractorToPresenterProtocol {
    
}
