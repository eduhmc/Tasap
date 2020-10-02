//
//  Calendar.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/4/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

struct CalendarModel {
    
    var isOnlyView: Bool
    var user: User?
    var course: Course?
    
    init(isOnlyView: Bool, user: User?, course: Course?) {
        self.isOnlyView = isOnlyView
        self.user = user
        self.course = course
    }
    
}
