//
//  RequestsPresenter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/24/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class RequestPresenter: RequestViewToPresenterProtocol {
    
    var view: RequestPresenterToViewProtocol?
    var intetactor: RequestPresenterToInteractorProtocol?
    var router: RequestPresenterToRouterProtocol?
    
    var state = "PENDING"
    
    var loader: Loader?
    
    private var requests: [Request] = []
    
    func stopObserving() {
        intetactor?.stopObserving()
    }
    
    func loadRequests(type: String, fromView: UIViewController) {
        loader = Loader(forView: fromView.view)
        loader?.showLoading()
        intetactor?.loadRequests(state: state, type: type)
    }
    
    func showRequestDetail(date: Date, fromView: UIViewController) {
        let requestsfiltered = self.requests.filter { $0.dateFormatted == date }
        router?.pushToRequestDetail(requests: requestsfiltered, fromView: fromView)
    }
}

extension RequestPresenter: RequestInteractorToPresenterProtocol {
    
    func fetchRequests(requests: [Request]) {
        
        var requestsFiltered = requests
        
        if state == "PENDING"{
            requestsFiltered = requests.filter { $0.endDate >= Date() }
        }
        
        self.requests = requestsFiltered
        let dates = requestsFiltered.map { $0.dateFormatted }
        let uniqueDates = Array(Set(dates)).sorted { $0 > $1 }
        
        let title = state == "PENDING" ? "Request": "Meeting"
        
        loader?.hideLoading()
        view?.showRequests(dates: uniqueDates, title: title)
    }
    
}
