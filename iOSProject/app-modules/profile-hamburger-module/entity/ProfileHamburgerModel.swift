//
//  ProfileHamburgerModel.swift
//  iOSProject
//
//  Created by everis on 8/24/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation

struct ProfileHamburgerModel {
    
    var userAuth: User
    var isHiddenCalendar: Bool
    var isHiddenTutorDetail: Bool
    var isHiddenCourseList: Bool
    var isHiddenUpdateCourseList: Bool
    
    init(userAuth: User) {
        self.userAuth = userAuth
        
        self.isHiddenCalendar = false
        self.isHiddenTutorDetail = false
        self.isHiddenCourseList = false
        self.isHiddenUpdateCourseList = false
        
        if !userAuth.isTutor {
            self.isHiddenTutorDetail = true
            self.isHiddenCourseList = true
            self.isHiddenUpdateCourseList = true
        }
        
    }
    
}
