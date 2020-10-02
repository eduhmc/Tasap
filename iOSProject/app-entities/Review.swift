//
//   Review.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/23/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Review {

    var author: String
    var comment: String
    var review: Int
    var course: String
    var date: String

    var dictionary: [String: Any] {
        
    return [
        "comment": comment,
        "review": review,
        "course": course,
        "date": date,
        "author": author
        ]
    }
    
    init(author: String, comment: String, review: Int, course: String, date: String) {
        self.author = author
        self.comment = comment
        self.review = review
        self.course = course
        self.date = date
    }
    
    var document: DocumentReference?
}

extension Review {
    
    init?(dictionary: [String : Any]) {
      guard let author = dictionary["author"] as? String,
             let comment = dictionary["comment"] as? String,
             let review = dictionary["review"] as? Int,
             let course = dictionary["course"] as? String,
             let date = dictionary["date"] as? String else { return nil }

        self.init(author: author, comment: comment, review: review, course: course, date: date)
    }
    
}
