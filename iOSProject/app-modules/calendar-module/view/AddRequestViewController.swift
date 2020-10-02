//
//  AddRequestViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/22/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PopupDialog

class AddRequestViewController: UIViewController {

    var tutor: User?
    var course: Course?
    var event: Eveent?
    
    var model: CalendarModel?
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var endDateView: UIView!
    
    var startDate: Date? {
        didSet {
            
            let locale = NSLocale.current
            let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
            if formatter.contains("a") {
                //phone is set to 12 hours
                startDateLabel.text = startDate!.format(with: "dd MMM YYYY HH:mm")
            } else {
                //phone is set to 24 hours
                startDateLabel.text = startDate!.format(with: "dd MMM YYYY HH:mm aa")
            }
            
        }
    }
    var endDate: Date? {
        didSet {
            
            let locale = NSLocale.current
            let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
            if formatter.contains("a") {
                //phone is set to 12 hours
                endDateLabel.text = endDate!.format(with: "dd MMM YYYY HH:mm")
            } else {
                //phone is set to 24 hours
                endDateLabel.text = endDate!.format(with: "dd MMM YYYY HH:mm aa")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let event = event {
            //startDateLabel.text = event.startDate.format(with: "dd MMM YYYY HH:mm aa")
            //endDateLabel.text = event.endDate.format(with: "dd MMM YYYY HH:mm aa")
            
            startDate = event.startDate
            endDate = event.endDate
            
        }
        
        let gesture1 = UITapGestureRecognizer(target: self, action:  #selector(self.startDateTapped))
        startDateView.addGestureRecognizer(gesture1)
        
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector(self.endDateTapped))
        endDateView.addGestureRecognizer(gesture2)

    }
    
    
    
    @objc func startDateTapped(sender : UITapGestureRecognizer) {
        presentDatePicker(date: startDate!, tag: 1)
    }
    
    @objc func endDateTapped(sender : UITapGestureRecognizer) {
        presentDatePicker(date: endDate!, tag: 2)
    }
    
    func presentDatePicker(date: Date, tag: Int) {
        let picker = DatePickerController()
        picker.date = date
        picker.datePicker.tag = tag
        picker.datePicker.minimumDate = event?.startDate
        picker.datePicker.maximumDate = event?.endDate
        picker.datePicker.minuteInterval = 30
        picker.delegate = self
        let navC = UINavigationController(rootViewController: picker)
        navigationController?.present(navC, animated: true, completion: nil)
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
            
        }else if startDate! >= endDate!{
            
            let popup =  PopupDialog(title: "Info", message: "The start date cannot be greater than the end date.")
                       
            let buttonOne = CancelButton(title: "OK") {
            }
                       
            popup.addButton(buttonOne)
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
                var request = Request(title: "USER", startDate: self.startDate!, endDate: self.endDate!, allDay: event.allDay, userID: tutor.document!.documentID, eventID: event.document!.documentID, requestUserID: ".", course: course.name, state: "PENDING", message: message, isRead: false)
                
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

extension AddRequestViewController: DatePickerControllerDelegate {
    
    func datePicker(controller: DatePickerController, didSelect date: Date?) {
        
        if let date = date {
            if controller.datePicker.tag == 1 {
                //startDateLabel.text = date.format(with: "dd MMM YYYY HH:mm aa")
                startDate = date
            }else {
                //endDateLabel.text = date.format(with: "dd MMM YYYY HH:mm aa")
                endDate = date
            }
        }
        
    }
    
}
