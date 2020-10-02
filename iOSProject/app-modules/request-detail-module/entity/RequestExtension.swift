//
//  Request.swift
//  iOSProject
//
//  Created by everis on 8/3/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import Foundation


extension Request {
    
    enum  TypeRequest {
        case myRequest
        case userRequest
    }
    
    var isOnTime : Bool {
        return endDate > Date()
    }
    
    var type: TypeRequest {
        return title == "USER" ? .myRequest : .userRequest
    }
    
}
