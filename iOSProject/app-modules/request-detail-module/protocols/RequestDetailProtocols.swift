//
//  RequestDetailProtocols.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/27/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit


protocol RequestDetailViewToPresenterProtocol: class {
    
    var view: RequestDetailPresenterToViewProtocol? {get set}
    var interactor: RequestDetailPresenterToInteractorProtocol? {get set}
    var router: RequestDetailPresenterToRouterProtocol? {get set}
    
    func loadDetail(isOnTime: Bool)
    func actionRequest(request:Request, view: UIViewController)
    func cancelRequest(request: Request, view: UIViewController)
    
}

protocol RequestDetailPresenterToViewProtocol: class {
    func showDetail(requests: [Request], hiddenSegmented: Bool)
}

protocol RequestDetailPresenterToInteractorProtocol: class {
    var presenter: RequestDetailInteractorToPresenterProtocol? {get set}
    func updateRequest(request: Request, state: String)
}

protocol RequestDetailInteractorToPresenterProtocol: class {
    func updatedRequest(message: String)
    func errorDatabase(message: String)
}

protocol RequestDetailPresenterToRouterProtocol: class {
    static func createRequestDetailModule(view: RequestDetailView, requests: [Request])
    func pushToUserChat(request: Request, userTwo: User, fromView: UIViewController)
    func popViewController(fromView: UIViewController)
}

