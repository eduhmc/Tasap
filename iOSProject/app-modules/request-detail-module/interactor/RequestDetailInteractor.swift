//
//  RequestDetailInteractor.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/27/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RequestDetailInteractor: RequestDetailPresenterToInteractorProtocol{
  
    var presenter: RequestDetailInteractorToPresenterProtocol?
    
    func updateRequest(request: Request, state: String) {
        
        request.document?.reference.updateData([
            "state": state,
            "isRead": true,
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                let error = "Error updating request, please try again"
                self.presenter?.errorDatabase(message: error)
            } else {
                print("1")
            Firestore.firestore().collection("users").document(request.userID).collection("requests").document(request.requestUserID).updateData([
                    "state": state,
                    "isRead": true,
                ]){ err in
                    
                    if let err = err {
                        print("Error updating document: \(err)")
                        let error = "Error updating request, please try again"
                        self.presenter?.errorDatabase(message: error)
                    } else {
                        print("2")
                        
                        self.updateEvent(request: request, state: state)
                    }
                }
            }
        }
        
    }
    
    private func updateEvent(request: Request, state: String) {
        
        if let userAuth = AuthenticationManager.shared.currentUser{
            
            UserAPI.shared.get(documentID: request.userID){ result in
                
                switch result {
                case .success(let document):
                    
                    if var user =  User(dictionary: document.data()!) {
                        
                        user.document = document.reference
                        
                        var messageGuest = "Your request has been rejected"
                        var messageUser = "A notification has been sent to the student, you can see this request in the meetings section"
                        
                        if state == "ACCEPTED" {
                            
                            self.cutEvent(request: request, userGuest: user)
                            messageGuest = "Your request has been approved"
                            
                        } else if state == "CANCELM" {
                    
                            messageGuest = "Your meeting has been cancelled"
                            messageUser = "A notification has been sent to the student"
                            
                        }
                        
                        let sender = PushNotificationAPI()
                        sender.sendPushNotification(to: user.fcmToken, title: "\(userAuth.first) \(userAuth.last)", body: messageGuest)
                        
                        self.presenter?.updatedRequest(message: messageUser)
                        
                    }
                    
                case .failure(let error):
                    print(error.message)
                    let error = "Error updating request, please try again"
                    self.presenter?.errorDatabase(message: error)
                }
                
            }
            
        }
        
    }
    
    private func cutEvent( request: Request, userGuest: User) {
        
        if let userAuth = AuthenticationManager.shared.currentUser{
            
            EventAPI.shared.get(user: userAuth, documentID: request.eventID) { result in
                
                switch result {
                case .success(let document):
                    
                    if var event = Eveent(dictionary: document.data()!) {
                        
                        event.document = document
                        
                        if event.startDate == request.startDate {
                            
                            if event.endDate == request.endDate {
                                
                                //update current event tutor
                                event.document?.reference.updateData([
                                    "title":"BUSY",
                                    "location": "\(userGuest.first) \(userGuest.last)"
                                ])
                                
                                //create event student
                                var eventStudent = event
                                eventStudent.title = "MEETING"
                                eventStudent.location = "\(userAuth.first) \(userAuth.last)"
                                EventAPI.shared.add(user: userGuest, event: eventStudent) { result in
                                    
                                    switch result {
                                    case .success(let eventID):
                                        print(eventID)
                                    case .failure(_):
                                    let error = "Error updating request, please try again"
                                    self.presenter?.errorDatabase(message: error)
                                    }
                                }
                                
                                
                                 
                            }else if event.endDate > request.endDate {
                                
                                //update current event with new end date
                                event.document?.reference.updateData([
                                    "title":"BUSY",
                                    "location": "\(userGuest.first) \(userGuest.last)",
                                    "endDate": request.endDate
                                ])
                                
                                //create event student
                                var eventStudent = event
                                eventStudent.title = "MEETING"
                                eventStudent.location = "\(userAuth.first) \(userAuth.last)"
                                eventStudent.endDate = request.endDate
                                EventAPI.shared.add(user: userGuest, event: eventStudent) { result in
                                    
                                    switch result {
                                    case .success(let eventID):
                                        print(eventID)
                                    case .failure(_):
                                    let error = "Error updating request, please try again"
                                    self.presenter?.errorDatabase(message: error)
                                    }
                                }
                                
                                //create new event tutor
                                var newEvent = event
                                newEvent.title = "FREE"
                                newEvent.startDate = request.endDate
                                
                                EventAPI.shared.add(user: userAuth, event: newEvent) { result in
                                    
                                    switch result {
                                    case .success(let documentID):
                                        print("create new event with id : \(documentID)")
                                    case .failure(_):
                                        let error = "Error updating request, please try again"
                                        self.presenter?.errorDatabase(message: error)
                                    }
                                    
                                }
                                
                              
                            }
                            
                        }else if event.startDate < request.startDate {
                            
                            if event.endDate == request.endDate {
                                
                                //update current event with new end date
                                event.document?.reference.updateData([
                                    "title":"BUSY",
                                    "location": "\(userGuest.first) \(userGuest.last)",
                                    "startDate": request.startDate
                                ])
                                
                                //create event student
                                var eventStudent = event
                                eventStudent.title = "MEETING"
                                eventStudent.location = "\(userAuth.first) \(userAuth.last)"
                                eventStudent.startDate = request.startDate
                                EventAPI.shared.add(user: userGuest, event: eventStudent) { result in
                                    
                                    switch result {
                                    case .success(let eventID):
                                        print(eventID)
                                    case .failure(_):
                                    let error = "Error updating request, please try again"
                                    self.presenter?.errorDatabase(message: error)
                                    }
                                }
                                
                                //create new event
                                var newEvent = event
                                newEvent.title = "FREE"
                                newEvent.endDate = request.startDate
                                
                                EventAPI.shared.add(user: userAuth, event: newEvent) { result in
                                    
                                    switch result {
                                    case .success(let documentID):
                                        print("create new event with id : \(documentID)")
                                    case .failure(_):
                                        let error = "Error updating request, please try again"
                                        self.presenter?.errorDatabase(message: error)
                                    }
                                    
                                }
                                 
                            }else if event.endDate > request.endDate {
                                
                                //update current event with new end date
                                event.document?.reference.updateData([
                                    "title":"BUSY",
                                    "location": "\(userGuest.first) \(userGuest.last)",
                                    "startDate": request.startDate,
                                    "endDate": request.endDate
                                ])
                                
                                //create event student
                                var eventStudent = event
                                eventStudent.title = "MEETING"
                                eventStudent.location = "\(userAuth.first) \(userAuth.last)"
                                eventStudent.startDate = request.startDate
                                eventStudent.endDate = request.endDate
                                EventAPI.shared.add(user: userGuest, event: eventStudent) { result in
                                    
                                    switch result {
                                    case .success(let eventID):
                                        print(eventID)
                                    case .failure(_):
                                    let error = "Error updating request, please try again"
                                    self.presenter?.errorDatabase(message: error)
                                    }
                                }
                                
                                //create before event
                                var beforeEvent = event
                                beforeEvent.title = "FREE"
                                beforeEvent.endDate = request.startDate
                                
                                EventAPI.shared.add(user: userAuth, event: beforeEvent) { result in
                                    
                                    switch result {
                                    case .success(let documentID):
                                        print("create new event with id : \(documentID)")
                                        
                                        //create after event
                                        var afterEvent = event
                                        afterEvent.title = "FREE"
                                        afterEvent.startDate = request.endDate
                                        
                                        EventAPI.shared.add(user: userAuth, event: afterEvent) { result in
                                            
                                            switch result {
                                            case .success(let documentID):
                                                print("create new event with id : \(documentID)")
                                            case .failure(_):
                                                let error = "Error updating request, please try again"
                                                self.presenter?.errorDatabase(message: error)
                                            }
                                            
                                        }
                                        
                                        
                                    case .failure(_):
                                        let error = "Error updating request, please try again"
                                        self.presenter?.errorDatabase(message: error)
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                    
                
                    
                case .failure(let error):
                    print(error.message)
                    let error = "Error updating request, please try again"
                    self.presenter?.errorDatabase(message: error)
                }
                
            }
            
        }
  
        
    }
    
}
