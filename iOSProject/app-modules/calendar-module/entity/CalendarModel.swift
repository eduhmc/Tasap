//
//  Calendar.swift
//  iOSProject
//
//  Created by everis on 8/4/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation

struct Calendar {
    
    var isOnlyView: Bool
    var user: User?
    var course: Course?
    
    init(isOnlyView: Bool, user: User?, course: Course?) {
        self.isOnlyView = isOnlyView
        self.user = user
        self.course = course
    }
    
}
