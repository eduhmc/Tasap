//
//  ProfileHamburgerRouter.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/24/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class ProfileHamburgerRouter: ProfileHamburgerPresenterToRouterProtocol {
    
   
    static func createProfileHamburgerModule(view: ProfileHamburgerView, parent: ProfileViewController) {
        let presenter = ProfileHamburgerPresenter(parent: parent)
        view.presenter = presenter
        view.presenter?.view = view
        view.presenter?.router = ProfileHamburgerRouter()
        view.presenter?.interactor = ProfileHamburgerInteractor()
        view.presenter?.interactor?.presenter = presenter
    }
    
    func pushToCalendarModule(fromView: UIViewController) {
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            
            let storyboard = UIStoryboard.init(name: "Calendar", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CalendarView") as! CalendarView
            
            let calendarModel = CalendarModel(isOnlyView: !userAuth.isTutor, user: userAuth, course: nil)
            
            CalendarRouter.createCalendarModule(view: vc, model: calendarModel)
            
            fromView.navigationController?.pushViewController(vc, animated: true)
            fromView.sideMenuController?.hideMenu()
            
        }
        
    }
    
    func pushToProfileDetailModule(fromView: UIViewController) {
        
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileDetailView") as! ProfileDetailViewController
        
        fromView.navigationController?.pushViewController(vc, animated: true)
        fromView.sideMenuController?.hideMenu()
        
    }
    
    func pushToCoursesListModule(fromView: UIViewController) {
        
        let storyboard = UIStoryboard.init(name: "MyCourses", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyCoursesView") as! MyCoursesView
        
        MyCoursesRouter.createMyCoursesModule(view: vc)
        
        fromView.navigationController?.pushViewController(vc, animated: true)
        fromView.sideMenuController?.hideMenu()

    }
    
    func pushToUpdateCoursesListModule(fromView: UIViewController) {
        
        let storyboard = UIStoryboard.init(name: "Course", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UpdateCareerView") as! UpdateCareerView
        
        fromView.navigationController?.pushViewController(vc, animated: true)
        fromView.sideMenuController?.hideMenu()
        
    }
    
    func pushToLoginModule(fromView: UIViewController) {
        
        if let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
            
            AuthenticationManager.shared.logout() { result in
                
                switch result {
                case .success(let bool):
                    
                    if bool {
                        
                        let ud = UserDefaults.standard
                        ud.removeObject(forKey: "currentUser")
                        
                        loginVC.modalPresentationStyle = .fullScreen
                        fromView.present(loginVC, animated: true, completion: nil)
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
            }
            
        }
        
    }
    
}
