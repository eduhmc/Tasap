//
//  RequestDetailPresenter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/27/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import PopupDialog

class RequestDetailPresenter: RequestDetailViewToPresenterProtocol {
    
    var view: RequestDetailPresenterToViewProtocol?
    var interactor: RequestDetailPresenterToInteractorProtocol?
    var router: RequestDetailPresenterToRouterProtocol?
    
    var requests: [Request]?

    var currentView: UIViewController?
    
    var loader: Loader?
    
    func loadDetail(isOnTime: Bool) {
        
        if requests![0].dateFormatted < Date(), requests![0].dateFormatted.day != Date().day {
            let requestsSorted = requests!.sorted { $0.startDate > $1.startDate  }
            view?.showDetail(requests: requestsSorted, hiddenSegmented: true)
        }else{
            
            let requestFiltered = requests!.filter { $0.isOnTime == isOnTime }
            let requestsSorted = requestFiltered.sorted { $0.startDate > $1.startDate  }
            view?.showDetail(requests: requestsSorted, hiddenSegmented: false)
        }
        
    }
    
    func actionRequest(request: Request, view: UIViewController) {
        
        self.currentView = view

        if request.type == .myRequest {
            
            UserAPI.shared.get(documentID: request.userID) { result in
                
                switch result {
                case .success(let document):
                    
                    if var userGuest = User(dictionary: document.data()!) {
                        userGuest.document = document.reference
                        self.router?.pushToUserChat(request: request, userTwo: userGuest, fromView: self.currentView!)
                    }
                    
                case .failure(_):
                    print("error")
                }
                
            }
            
        }else{
            
            if request.state == "ACCEPTED" {
                
                UserAPI.shared.get(documentID: request.userID) { result in
                    
                    switch result {
                    case .success(let document):
                        
                        if var userGuest = User(dictionary: document.data()!) {
                            userGuest.document = document.reference
                            self.router?.pushToUserChat(request: request, userTwo: userGuest, fromView: self.currentView!)
                        }
                        
                    case .failure(_):
                        print("error")
                    }
                    
                }
                
            }else{
                
                loader = Loader(forView: currentView!.view)
                loader?.hideLoading()
                
                let popup =  PopupDialog(title: "Pending Request", message:  "If you accept the request, the status of your associated event will be updated to busy. If you reject it, the request will be deleted. \n \n User Message : \(request.message)")
                
                let buttonOne = DefaultButton(title: "Accept") {
                    self.loader?.showLoading()
                    self.interactor?.updateRequest(request: request, state: "ACCEPTED")
                }
                
                let buttonTwo = DestructiveButton(title: "Reject") {
                    self.loader?.showLoading()
                    self.interactor?.updateRequest(request: request, state: "REJECTED")
                }
                
                let buttonThree = CancelButton(title: "Cancel") {
                    self.loader?.hideLoading()
                }
                
                popup.addButton(buttonOne)
                popup.addButton(buttonTwo)
                popup.addButton(buttonThree)
                
                view.present(popup, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func cancelRequest(request: Request, view: UIViewController) {
        
        self.currentView = view
        loader = Loader(forView: currentView!.view)
        loader?.showLoading()
        
        interactor?.updateRequest(request: request, state: "CANCELM")
    }
    
}

extension RequestDetailPresenter: RequestDetailInteractorToPresenterProtocol {
    func updatedRequest(message: String) {
        
        self.loader?.hideLoading()
        
        let popup =  PopupDialog(title: "Info", message:  message)
        
        let buttonOne = DefaultButton(title: "Accept") {
            
            self.router?.popViewController(fromView: self.currentView!)
        }
        
        popup.addButton(buttonOne)
        currentView?.present(popup, animated: true, completion: nil)
        
    }
    
    func deletedRequest(message: String) {
        
        self.loader?.hideLoading()
        
        let popup =  PopupDialog(title: "Info", message:  message)
        
        let buttonOne = DefaultButton(title: "Accept") {
            
            self.router?.popViewController(fromView: self.currentView!)
        }
        
        popup.addButton(buttonOne)
        currentView?.present(popup, animated: true, completion: nil)
        
    }
    
    
    func errorDatabase(message: String) {
        
        let popup =  PopupDialog(title: "Error", message:  message)
        
        let buttonOne = DefaultButton(title: "Accept") {
        }
        
        popup.addButton(buttonOne)
        currentView?.present(popup, animated: true, completion: nil)
    }
    
}
