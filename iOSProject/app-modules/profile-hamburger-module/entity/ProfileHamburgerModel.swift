//
//  ProfileHamburgerModel.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/24/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

struct ProfileHamburgerModel {
    
    var userAuth: User
    var isHiddenCalendar: Bool
    var isHiddenTutorDetail: Bool
    var isHiddenCourseList: Bool
    var isHiddenUpdateCourseList: Bool
    var updateCourseListButtonText:String
    
    init(userAuth: User) {
        self.userAuth = userAuth
        
        self.isHiddenCalendar = false
        self.isHiddenTutorDetail = false
        self.isHiddenCourseList = false
        self.isHiddenUpdateCourseList = false
        
        self.updateCourseListButtonText = " Update course list"
        
        if !userAuth.isTutor {
            self.isHiddenTutorDetail = true
            self.isHiddenCourseList = true
            self.updateCourseListButtonText = " I want to be a tutor"
        }
        
    }
    
    let hamburgerSectionText = "You are in the menu profile section"
    var calendarText: String {
        
        var text = ""
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            if userAuth.isTutor {
                text = "This is your calendar, where you can add and view your meetings."
            }else {
                text = "This is your calendar, where you can view your meetings."
            }
        }
        return text
    }
    let profileTutorText = "This is the tutor's profile, here you can find your reviews and edit your tutor options"
    let updateCoursesListText = "Here you can update the courses you give tutoring"
    let nextButtonText = "Ok!"
    
}
