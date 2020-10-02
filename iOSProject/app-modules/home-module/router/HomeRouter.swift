//
//  HomeRouter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/11/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class HomeRouter: HomePresenterToRouterProtocol {
    
    static func createHomeModule(view: HomeView) {
        
        let presenter = HomePresenter()
        view.presenter = presenter
        view.presenter?.view = view
        view.presenter?.router = HomeRouter()
        view.presenter?.interactor = HomeInteractor()
        view.presenter?.interactor?.presenter = presenter
        
    }
    
    func pushToChatModule(chatsNoRead: [String], fromView: UIViewController) {
        
        let storyboard = UIStoryboard.init(name: "Chat", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatsViewController") as! ChatsViewController
        vc.chatsNoRead = chatsNoRead
        vc.modalPresentationStyle = .automatic
        fromView.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
