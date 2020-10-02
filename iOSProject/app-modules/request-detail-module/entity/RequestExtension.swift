//
//  Request.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/3/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
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
