//
//  HomePresenter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/11/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class HomePresenter: HomeViewToPresenterProtocol {
    
    var view: HomePresenterToViewProtocol?
    var interactor: HomePresenterToInteractorProtocol?
    var router: HomePresenterToRouterProtocol?
    
    var chatsNoReads:[String] = []
    var loader: Loader?
    
    func loadInformation(view: UIViewController) {
        loader = Loader(forView: view.view)
        loader?.showLoading()
        interactor?.loadInformation()
    }
    
    func loadNumberOfRequest() {
        interactor?.loadNumberOfRequest()
    }
    
    func loadNumberOfChats() {
        interactor?.loadNumberOfChats()
    }
    
    func showChatModule(fromView: UIViewController) {
        router?.pushToChatModule(chatsNoRead: chatsNoReads, fromView: fromView)
    }
    
    
}

extension HomePresenter: HomeInteractorToPresenterProtocol {
    
    func loadedInformation(model: HomeModel) {
        loader?.hideLoading()
        view?.showInformation(model: model)
    }
    
    func loadedNumberOfRequest(number: Int) {
        view?.showNumberOfRequest(number: number)
    }
    
    func loadesNumberOfChats(number: Int, chatsNoRead: [String]) {
        
        chatsNoReads = chatsNoRead
        view?.showNumberOfChats(number: number)
    }
    
}
