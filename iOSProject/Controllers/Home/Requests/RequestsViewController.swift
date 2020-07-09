//
//  RequestsViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/6/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import PopupDialog
import FirebaseFirestore

class RequestsViewController: UIViewController {

    @IBOutlet weak var requestSegmented: UISegmentedControl!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var user: User?
    
    var state = "PENDING"
    
    private var requestsFiltered: [Request] = [] {
        didSet {
            
            emptyLabel.isHidden = requestsFiltered.count > 0
            reviewTableView.reloadData()
        }
    }

    private var requests: [Request] = [] {
        didSet {
            let requestsSorted = requests.sorted { $0.startDate < $1.startDate  }
            requests = requestsSorted
            
            let type =  isMyRequest ? "USER" : "TUTOR"
            requestsFiltered = requests.filter { $0.title == type && $0.startDate >= Date() }
            print(Date())
       }
    }
    
    var isMyRequest = true
    
    private var listener: ListenerRegistration?

    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
       
    fileprivate func observeQuery() {
      guard let query = query else { return }
      stopObserving()

      listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
        guard let snapshot = snapshot else {
          print("Error fetching snapshot results: \(error!)")
          return
        }
        let models = snapshot.documents.map { (document) -> Request in
          if var model = Request(dictionary: document.data()) {
            model.document = document
            return model
          } else {
            // Don't use fatalError here in a real app.
            fatalError("Unable to initialize type \(Request.self) with dictionary \(document.data())")
          }
        }
        self.requests = models
      }

    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return user!.document!.collection("requests").whereField("state", isEqualTo: state)
       // return Firestore.firestore().collectionGroup("reviews").whereField("author", isEqualTo: self.user!.document!.documentID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        observeQuery()
    }
       
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
    
    func setup(){
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        requestSegmented.removeAllSegments()
        requestSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        if state == "PENDING" {
            title = "Requests"
            emptyLabel.text = "No pending requests"
            requestSegmented.insertSegment(withTitle: "My Requests", at: 0, animated: false)
            requestSegmented.insertSegment(withTitle: "User Requests", at: 1, animated: false)
            
        }else{
            title = "Meetings"
            emptyLabel.text = "No pending meetings"
            requestSegmented.insertSegment(withTitle: "My Meetings", at: 0, animated: false)
            requestSegmented.insertSegment(withTitle: "User Meetings", at: 1, animated: false)
        }
        
        requestSegmented.selectedSegmentIndex = 0
        
        query = baseQuery()
 
    }
    
    deinit {
        listener?.remove()
    }
    
    
    @IBAction func requestSegmentedTapped(_ sender: Any) {
        
        isMyRequest = requestSegmented.selectedSegmentIndex == 0 ? true : false
        let type =  isMyRequest ? "USER" : "TUTOR"
        requestsFiltered = requests.filter { $0.title == type && $0.startDate >= Date() }

    }
    
    func updateRequest(request: Request){
        
        let loader = Loader(forView: self.view)
        
        loader.showLoading()
        
        request.document?.reference.updateData([
            "state": request.state
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                loader.hideLoading()
            } else {
                print("Document successfully updated")
                
                Firestore.firestore().collection("users").document(request.userID).collection("requests").document(request.requestUserID).updateData([
                    "state": request.state
                ]){ err in
                
                    if let err = err {
                        print("Error updating document: \(err)")
                        loader.hideLoading()
                    } else {
                        print("Document successfully updated")
                        
                        if let userAuth = AuthenticationManager.shared.currentUser{
                            
                            UserAPI.shared.get(documentID: request.userID){ result in
                                
                                switch result {
                                case .success(let document):
                                    
                                    if let user =  User(dictionary: document.data()!) {
                                      
                                        
                                        var message = "Your request has been rejected"
                                        
                                        if request.state == "ACCEPTED" {
                                            
                                            userAuth.document?.collection("events").document(request.eventID).updateData([
                                                "title":"BUSY",
                                                "location": "\(user.first) \(user.last)"
                                            ])
                                            
                                            message = "Your request has been approved"
                                        }
                                        
                                        let sender = PushNotificationAPI()
                                        sender.sendPushNotification(to: user.fcmToken, title: "\(userAuth.first) \(userAuth.last)", body: message)
                
                                        loader.hideLoading()
                                    }
                                    
                                case .failure(let error):
                                    loader.hideLoading()
                                    print(error.message)
                                }
                                
                            }
                           
                        }
  
                    }
                }
            }
        }
    }
    

}

extension RequestsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        if state == "PENDING" {
            
            if !isMyRequest {
                
                var request = requestsFiltered[indexPath.row]
             
                let popup =  PopupDialog(title: "Pending Request", message:  " If you accept the request, the status of your associated event will be updated to busy. If you reject it, the request will be deleted. \n \n User Message : \(request.message)")
                
                let buttonOne = DefaultButton(title: "Accept") {
                    request.state = "ACCEPTED"
                    self.updateRequest(request: request)
                }
                
                let buttonTwo = DestructiveButton(title: "Reject") {
                    request.state = "REJECTED"
                    self.updateRequest(request: request)
                }
                
                let buttonThree = CancelButton(title: "Cancel") {
                }
                
                popup.addButton(buttonOne)
                popup.addButton(buttonTwo)
                popup.addButton(buttonThree)
                
                self.present(popup, animated: true, completion: nil)
                
            }
        }
        
    }
    
}

extension RequestsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 176
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestsFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestCell
        let request = requestsFiltered[indexPath.row]
        cell.setup(request: request)
        return cell
        
    }
    
}
