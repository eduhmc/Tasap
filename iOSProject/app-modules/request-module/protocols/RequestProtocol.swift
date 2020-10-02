//
//  RequestProtocol.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/28/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol RequestViewToPresenterProtocol: class {
    
    var view: RequestPresenterToViewProtocol? {get set}
    var intetactor: RequestPresenterToInteractorProtocol? {get set}
    var router: RequestPresenterToRouterProtocol? {get set}
    
    func stopObserving()
    func loadRequests(type: String, fromView: UIViewController)
    func showRequestDetail(date: Date, fromView: UIViewController)
    
}

protocol RequestPresenterToViewProtocol: class {
    func showRequests(dates: [Date], title: String)
}

protocol RequestPresenterToInteractorProtocol: class {
    var presenter: RequestInteractorToPresenterProtocol? {get set}
    
    func stopObserving()
    func loadRequests(state: String, type: String)
}

protocol RequestInteractorToPresenterProtocol: class {
    func fetchRequests(requests: [Request])
}

protocol RequestPresenterToRouterProtocol: class {
    static func createRequestModule(view: RequestView, state: String)
    func pushToRequestDetail(requests: [Request], fromView: UIViewController)
}
