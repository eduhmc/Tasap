//
//  CalendarProtocols.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/4/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

protocol CalendarViewToPresenterProtocol: class {
    
    var view: CalendarPresenterToViewProtocol? {get set}
    var interactor: CalendarPresenterToInteractorProtocol? {get set}
    var router: CalendarPresenterToRouterProtocol? {get set}
    
    func loadEvents()
    
}

protocol CalendarPresenterToViewProtocol: class {
    func showEvents(model: CalendarModel)
}

protocol CalendarPresenterToInteractorProtocol: class {
    var presenter: CalendarInteractorToPresenterProtocol? {get set}
}

protocol CalendarInteractorToPresenterProtocol: class {
    
}

protocol CalendarPresenterToRouterProtocol: class {
    static func createCalendarModule(view: CalendarView, model: CalendarModel)
}
