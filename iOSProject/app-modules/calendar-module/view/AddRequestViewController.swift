//
//  AddRequestViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/22/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PopupDialog

class AddRequestViewController: UIViewController {

    var tutor: User?
    var course: Course?
    var event: Eveent?
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let event = event {
            startDateLabel.text = event.startDate.format(with: "dd MMM YYYY HH:mm aa")
            endDateLabel.text = event.endDate.format(with: "dd MMM YYYY HH:mm aa")
        }
        
    }
    
    @IBAction func sendRequestButtonTapped(_ sender: Any) {
        
        guard let event = self.event, let message = self.messageTextField.text else {
            return
        }
        
        if message.count > 0 {
            
            let popup =  PopupDialog(title: "Info", message: "After submitting the tutoring request, don't forget to arrange with the tutor so they can approve it.")
            
            let buttonOne = DefaultButton(title: "OK") {
                self.createRequest(event,message)
            }
            
            let buttonTwo = CancelButton(title: "Cancel") {
            }
            
            popup.addButton(buttonOne)
            popup.addButton(buttonTwo)
            
            self.present(popup, animated: true, completion: nil)
            
        }else {
            
            let popup =  PopupDialog(title: "Info", message: "Please enter the message.")
                       
            let buttonOne = CancelButton(title: "OK") {
            }
                       
            popup.addButton(buttonOne)
            self.present(popup, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    private func createRequest(_ event: Eveent,_ message: String) {
        
        guard let tutor = self.tutor else {
            return
        }
        
        let loader = Loader(forView: self.view)
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            if let course = self.course {
                
                loader.showLoading()
                var request = Request(title: "USER", startDate: event.startDate, endDate: event.endDate, allDay: event.allDay, userID: tutor.document!.documentID, eventID: event.document!.documentID, requestUserID: ".", course: course.name, state: "PENDING", message: message)
                
                var ref: DocumentReference? = nil
                ref = userAuth.document!.collection("requests").addDocument(data: request.dictionary)  { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        loader.hideLoading()
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        loader.hideLoading()
                        request.requestUserID = ref!.documentID
                        self.createRequestTutor(request: request)
                    }
                }
            }
        }
    }
    
    private func createRequestTutor(request: Request){
        
        guard let userAuth = AuthenticationManager.shared.currentUser else {
            return
        }
        
        var request = request
        request.title = "TUTOR"
        request.userID = userAuth.document!.documentID
        
        let loader = Loader(forView: self.view)
        
        if let tutor = self.tutor {
            
            var ref: DocumentReference? = nil
            ref = tutor.document!.collection("requests").addDocument(data: request.dictionary)  { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    loader.hideLoading()
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    loader.hideLoading()
                    
                    let sender = PushNotificationAPI()
                    sender.sendPushNotification(to: tutor.fcmToken, title: "\(userAuth.first)'s Request", body: "\(request.message) \nDate: \(request.startDate.format(with: "dd MMM YYYY HH:mm aa")) - \(request.endDate.format(with: "dd MMM YYYY HH:mm aa")) ")
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
}
