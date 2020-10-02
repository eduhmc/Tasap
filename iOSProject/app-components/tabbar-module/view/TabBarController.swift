//
//  TabBarController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/18/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import SideMenuSwift

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeSB = UIStoryboard.init(name: "Main", bundle: nil)
        let homeVC = homeSB.instantiateViewController(withIdentifier: "HomeView") as! HomeView
        HomeRouter.createHomeModule(view: homeVC)
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        let homeNC = UINavigationController(rootViewController: homeVC)
        homeNC.navigationBar.barTintColor =  UIColor(hexString: "0B516E", alpha: 0.5)
        homeNC.navigationBar.tintColor = UIColor.white
        homeNC.navigationBar.prefersLargeTitles = true
        homeNC.navigationBar.isTranslucent = true
        let homeTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        homeNC.navigationBar.titleTextAttributes = homeTextAttributes
        homeNC.navigationBar.largeTitleTextAttributes = homeTextAttributes
        
        /*let profileSB = UIStoryboard.init(name: "Profile", bundle: nil)
        let profileSM = profileSB.instantiateViewController(withIdentifier: "SideMenu") as! SideMenuController
        
        profileSM.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle.fill"), tag: 1)*/
        
        //MARK: PROFILE
        let profileSB = UIStoryboard.init(name: "Profile", bundle: nil)
        let profileVC = profileSB.instantiateViewController(withIdentifier: "ProfileView") as! ProfileViewController
        
        let profileNC = UINavigationController(rootViewController: profileVC)
        profileNC.navigationBar.barTintColor =  UIColor(hexString: "0B516E", alpha: 0.5)
        profileNC.navigationBar.tintColor = UIColor.white
        profileNC.navigationBar.prefersLargeTitles = true
        profileNC.navigationBar.isTranslucent = true
        let profileTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        profileNC.navigationBar.titleTextAttributes = profileTextAttributes
        profileNC.navigationBar.largeTitleTextAttributes = profileTextAttributes
        

        let profileHamburgerVC = profileSB.instantiateViewController(withIdentifier: "MenuNavigation") as! ProfileHamburgerView
        ProfileHamburgerRouter.createProfileHamburgerModule(view: profileHamburgerVC, parent: profileVC)
        
        let profileSM = SideMenuController(contentViewController: profileNC, menuViewController: profileHamburgerVC)
        profileSM.extendedLayoutIncludesOpaqueBars = true
        profileSM.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle.fill"), tag: 1)
        
        SideMenuController.preferences.basic.position = .sideBySide
        SideMenuController.preferences.basic.menuWidth = 240
        SideMenuController.preferences.basic.defaultCacheKey = "0"
        SideMenuController.preferences.basic.direction = .right
        
        
       
        let tabBarList = [homeNC, profileSM]
        
        self.setup()

        viewControllers = tabBarList
    }
    
    func setup() {
        self.tabBar.tintColor = UIColor.white
        self.tabBar.barTintColor = UIColor(hexString: "#0B516E")
        self.tabBar.isTranslucent = false
    }

}

extension TabBarController: SideMenuControllerDelegate {
    func sideMenuController(_ sideMenuController: SideMenuController,
                            animationControllerFrom fromVC: UIViewController,
                            to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BasicTransitionAnimator(options: .transitionFlipFromLeft, duration: 0.6)
    }

    func sideMenuController(_ sideMenuController: SideMenuController, willShow viewController: UIViewController, animated: Bool) {
        print("[Example] View controller will show [\(viewController)]")
    }

    func sideMenuController(_ sideMenuController: SideMenuController, didShow viewController: UIViewController, animated: Bool) {
        print("[Example] View controller did show [\(viewController)]")
    }

    func sideMenuControllerWillHideMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu will hide")
    }

    func sideMenuControllerDidHideMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu did hide.")
    }

    func sideMenuControllerWillRevealMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu will reveal.")
    }

    func sideMenuControllerDidRevealMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu did reveal.")
    }
}
