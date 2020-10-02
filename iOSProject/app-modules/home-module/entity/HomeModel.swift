//
//  HomeModel.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/12/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation


struct HomeModel {
    
    var university: University
    var numberRequest:Int = 0
    var numberChats:Int = 0
    
    var isFirstHome: Bool {
        get {
            return UserDefaultManager.shared.isFirstHome
        }
        set {
            UserDefaultManager.shared.isFirstHome = newValue
        }
    }
    
    init(university: University) {
        self.university = university
    }
    
    // MARK: TUTORIAL
    let homeSectionText = "You are in the Home section"
    let findTutorText = "In this section you can find the best tutors!"
    let chatText = "In this section you will find all the conversations you start"
    let requestText = "In this section you will see the requests that you send or receive"
    let meetingText = "In this section you will see all the accepted requests"
    let nextButtonText = "OK!"
    
}
