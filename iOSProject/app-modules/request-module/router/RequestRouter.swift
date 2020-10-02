//
//  RequestRouter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/27/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class RequestRouter: RequestPresenterToRouterProtocol{
    
    static func createRequestModule(view: RequestView, state: String) {
        
        let presenter = RequestPresenter()
        presenter.state = state
        view.presenter = presenter
        view.presenter?.view = view
        view.presenter?.router = RequestRouter()
        view.presenter?.intetactor = RequestInteractor()
        view.presenter?.intetactor?.presenter = presenter
        
    }
    
    func pushToRequestDetail(requests: [Request], fromView: UIViewController) {
        
        let storyboard = UIStoryboard.init(name: "Request", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RequestDetailView") as! RequestDetailView
        
        RequestDetailRouter.createRequestDetailModule(view: vc, requests: requests)
        vc.modalPresentationStyle = .automatic
        fromView.navigationController?.pushViewController(vc, animated: true)
        
    }
 
}
