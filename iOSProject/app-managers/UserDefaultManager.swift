//
//  UserDefaultManager.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 6/13/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation


class UserDefaultManager {
    
    static let shared = UserDefaultManager()
    
    var isFirstHome: Bool {
        
        get {
            let ud = UserDefaults.standard
            return ud.bool(forKey: "isFirstHome")
        }
        set{
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: "isFirstHome")
        }
        
    }
    
    var isFirstProfile: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.bool(forKey: "isFirstProfile")
        }
        set{
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: "isFirstProfile")
        }
    }
    
    var isFirstProfileDetail: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.bool(forKey: "isFirstProfileDetail")
        }
        set{
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: "isFirstProfileDetail")
        }
    }
    
    var isFirstHamburgerProfile: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.bool(forKey: "isFirstHamburgerProfile")
        }
        set{
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: "isFirstHamburgerProfile")
        }
    }
    
    var isFirstCalendar: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.bool(forKey: "isFirstCalendar")
        }
        set{
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: "isFirstCalendar")
        }
    }
    
    var isFirstUpdateCareer: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.bool(forKey: "isFirstUpdateCareer")
        }
        set{
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: "isFirstUpdateCareer")
        }
    }
    
    var isFirstAddEvent: Bool{
        get {
            let ud = UserDefaults.standard
            return ud.bool(forKey: "isFirstAddEvent")
        }
        set{
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: "isFirstAddEvent")
        }
    }
    
    init() {
        
    }
    
    func setupAppDelegate() {
        
        let ud = UserDefaults.standard
        
        if  !ud.bool(forKey: "isConfigAppDelegate") {
            
            ud.set(true, forKey: "isConfigAppDelegate")
            isFirstCalendar = true
            isFirstAddEvent = true
            ud.set(true, forKey: "isFirstHome")
            ud.set(true, forKey: "isFirstProfile")
            ud.set(true, forKey: "isFirstHamburgerProfile")
            ud.set(true, forKey: "isFirstProfileDetail")
            ud.set(true, forKey: "isFirstUpdateCareer")
            ud.set(true, forKey: "isFirstProfileCreateEvent")
            
        }
    }
    
    
}
