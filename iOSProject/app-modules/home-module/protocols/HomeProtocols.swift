//
//  HomeProtocoles.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/11/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

protocol HomeViewToPresenterProtocol: class {
    
    var view: HomePresenterToViewProtocol? {get set}
    var interactor: HomePresenterToInteractorProtocol? {get set}
    var router: HomePresenterToRouterProtocol? {get set}
    
    func loadInformation(view: UIViewController)
    
    func loadNumberOfRequest()
    func loadNumberOfChats()
    func showChatModule(fromView: UIViewController)
}

protocol HomePresenterToViewProtocol: class {
    func showInformation(model: HomeModel)
    func showNumberOfRequest(number: Int)
    func showNumberOfChats(number: Int)
}

protocol HomePresenterToInteractorProtocol: class {
    var presenter: HomeInteractorToPresenterProtocol? {get set}
    
    func loadInformation()
    func loadNumberOfRequest()
    func loadNumberOfChats()
}

protocol HomeInteractorToPresenterProtocol: class {
    
    func loadedInformation(model: HomeModel)
    func loadedNumberOfRequest(number: Int)
    func loadesNumberOfChats(number: Int, chatsNoRead: [String])
}

protocol HomePresenterToRouterProtocol: class {
    
    static func createHomeModule(view: HomeView)
    
    func pushToChatModule(chatsNoRead: [String], fromView: UIViewController)
    
}


