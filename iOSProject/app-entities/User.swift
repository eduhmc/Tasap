//
//  User.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/9/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation
import Firebase

struct User {

    public var first: String
    public var last: String
    public var description: String
    public var email: String
    public var password: String
    public var imagePath: String
    public var price: String
    public var ratingNumber: Int
    public var ratingAverage: Double
    public var courses: [String]
    public var university: String
    public var fcmToken: String
    public var country: String
    public var credentials: Credentials?
    
    public var image: UIImageView?

    var dictionary: [String: Any] {
    return [
        "first": first,
        "last": last,
        "description": description,
        "email": email,
        "password": password,
        "imagePath": imagePath,
        "price": price,
        "ratingNumber": ratingNumber,
        "ratingAverage": ratingAverage,
        "courses": courses,
        "university": university,
        "fcmToken": fcmToken,
        "country": country
        ]
    }
    
    init(first: String, last: String, description: String, email: String, password: String, imagePath: String, price: String, ratingNumber: Int, ratingAverage: Double, courses: [String], university: String, fcmToken: String, country: String) {
        self.first = first
        self.last = last
        self.description = description
        self.email = email
        self.password = password
        self.imagePath = imagePath
        self.price = price
        self.ratingNumber = ratingNumber
        self.ratingAverage = ratingAverage
        self.courses = courses
        self.university = university
        self.fcmToken = fcmToken
        self.country = country
    }
    
    var nameFirstLetter: String {
        return String(self.first[self.first.startIndex]).uppercased()
    }
    
    var nameComplete: String {
        return "\(self.first) \(self.last)"
    }
    
    var isTutor: Bool {
        return self.courses.count > 1
    }
    
    var document: DocumentReference?
    
   
    
}

extension User {
    
    init?(dictionary: [String : Any]) {
        guard let first = dictionary["first"] as? String,
             let last = dictionary["last"] as? String,
             let description = dictionary["description"] as? String,
             let email = dictionary["email"] as? String,
             let password = dictionary["password"] as? String,
             let imagePath = dictionary["imagePath"] as? String,
             let price = dictionary["price"] as? String,
             let ratingNumber = dictionary["ratingNumber"] as? Int,
             let ratingAverage = dictionary["ratingAverage"] as? Double,
             let courses = dictionary["courses"] as? [String],
             let university = dictionary["university"] as? String,
             let fcmToken = dictionary["fcmToken"] as? String,
             let country = dictionary["country"]as? String else { return nil }

        self.init(first: first, last: last, description: description, email: email, password: password, imagePath: imagePath, price: price, ratingNumber: ratingNumber, ratingAverage: ratingAverage, courses: courses, university: university, fcmToken: fcmToken, country: country)
    }
}

extension User {
    
    public struct Credentials: Equatable {
        
        public var email: String
        public var password: String
        
        var dictionary: [String: Any] {
        return [
            "email": email,
            "password": password
            ]
        }
        
        public init(email: String, password: String) {
            self.email = email
            self.password = password
        }
        
        init?(dictionary: [String : Any]) {
            guard let email = dictionary["email"] as? String,
                 let password = dictionary["password"] as? String else { return nil }

            self.init(email: email, password: password)
        }
        
        public static func ==(lhs: Credentials, rhs: Credentials) -> Bool {
            return lhs.email == rhs.email &&
                lhs.password == rhs.password
        }
        
    }
    
}
