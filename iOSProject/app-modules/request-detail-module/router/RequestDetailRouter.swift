//
//  RequestDetailRouter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/27/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class RequestDetailRouter: RequestDetailPresenterToRouterProtocol {
    
    static func createRequestDetailModule(view: RequestDetailView, requests: [Request]){
        
        let presenter = RequestDetailPresenter()
        presenter.requests = requests
        view.presenter = presenter
        view.presenter?.view = view
        view.presenter?.router = RequestDetailRouter()
        view.presenter?.interactor = RequestDetailInteractor()
        view.presenter?.interactor?.presenter = presenter
        
    }
    
    func pushToUserChat(request: Request, userTwo: User, fromView: UIViewController) {
        
        let storyboard = UIStoryboard.init(name: "Chat", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        vc.user2Name = "\(userTwo.first) \(userTwo.last)"
        vc.user2UID = userTwo.document?.documentID
        vc.user2ImgUrl = userTwo.imagePath
        vc.user2FcmToken = userTwo.fcmToken
        
        vc.modalPresentationStyle = .automatic
        fromView.navigationController?.pushViewController(vc, animated: true)
  
    }
    
    func popViewController(fromView: UIViewController) {
        _ = fromView.navigationController?.popViewController(animated: true)
    }
    
}
