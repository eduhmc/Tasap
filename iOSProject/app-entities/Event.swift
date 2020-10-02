//
//  Event.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/13/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import Firebase

struct Eveent {

    var title: String
    var location: String
    var startDate: Date
    var endDate: Date
    var allDay: Bool
    
    var dictionary: [String: Any] {
    return [
        "title": title,
        "location": location,
        "startDate": startDate,
        "endDate": endDate,
        "allDay": allDay
        ]
    }
    
    init(title: String, location: String, startDate: Date, endDate: Date, allDay: Bool) {
        self.title = title
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.allDay = allDay
    }
 
    var document: DocumentSnapshot?

}

extension Eveent {
    
    init?(dictionary: [String : Any]) {
        guard let title = dictionary["title"] as? String,
               let location = dictionary["location"] as? String,
               let startDate = dictionary["startDate"] as? Timestamp,
               let endDate = dictionary["endDate"] as? Timestamp,
               let allDay = dictionary["allDay"] as? Bool else { return nil }
        
        self.init(title: title, location: location, startDate: startDate.dateValue(), endDate: endDate.dateValue(), allDay: allDay)
    }
    
}
