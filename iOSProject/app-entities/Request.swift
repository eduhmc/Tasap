//
//  Request.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/20/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import Firebase

struct Request {

    var title: String
    var startDate: Date
    var endDate: Date
    var allDay: Bool
    var userID: String
    var eventID: String
    var requestUserID: String
    var course: String
    var state: String
    var message: String
    var isRead: Bool
    
    var dictionary: [String: Any] {
    return [
        "title": title,
        "startDate": startDate,
        "endDate": endDate,
        "allDay": allDay,
        "userID": userID,
        "eventID": eventID,
        "requestUserID": requestUserID,
        "course": course,
        "state": state,
        "message": message,
        "isRead": isRead
        ]
    }
    
    init(title: String, startDate: Date, endDate: Date, allDay: Bool, userID: String, eventID: String, requestUserID: String, course: String, state: String, message: String, isRead: Bool) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.allDay = allDay
        self.userID = userID
        self.eventID = eventID
        self.requestUserID = requestUserID
        self.course = course
        self.state = state
        self.message = message
        self.isRead = isRead
    }
 
    var document: DocumentSnapshot?
    
    var dateFormatted: Date {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy/MM/dd"
        return formater.date(from: "\(startDate.year)/\(startDate.month)/\(startDate.day)")!
    }
    
    

}

extension Request {
    
    init?(dictionary: [String : Any]) {
        guard let title = dictionary["title"] as? String,
               let startDate = dictionary["startDate"] as? Timestamp,
               let endDate = dictionary["endDate"] as? Timestamp,
               let allDay = dictionary["allDay"] as? Bool,
               let userID = dictionary["userID"] as? String,
               let eventID = dictionary["eventID"] as? String,
               let requestUserID = dictionary["requestUserID"] as? String,
               let course = dictionary["course"] as? String,
               let state = dictionary["state"] as? String,
               let message = dictionary["message"] as? String,
               let isRead = dictionary["isRead"] as? Bool else { return nil }
        
        self.init(title: title, startDate: startDate.dateValue(), endDate: endDate.dateValue(), allDay: allDay, userID: userID, eventID: eventID, requestUserID: requestUserID, course: course, state: state, message: message, isRead: isRead
        )
    }
  
}
