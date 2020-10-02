//
//  RegisterTutorViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/11/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PopupDialog
import FirebaseStorage
import FirebaseAuth

protocol RegisterTutorDelegate: class {
    func fetchUser(user: User)
    func registerUser(user: User)
}

class RegisterTutorViewController: UIViewController {

    @IBOutlet weak var careerTableView: UITableView!
    
    var user: User?
    var isChangePhoto: Bool?
    
    private var sortedFirstLetters: [String] = []
    private var sections: [[Career]] = [[]]
    
    private var careers: [Career] = [] {
        didSet {
            let firstLetters = careers.map { $0.nameFirstLetter }
            let uniqueFirstLetters = Array(Set(firstLetters))
            
            sortedFirstLetters = uniqueFirstLetters.sorted()
            sections = sortedFirstLetters.map { firstLetter in
                return careers
                    .filter { $0.nameFirstLetter == firstLetter }
                    .sorted { $0.name < $1.name }
            }
            
            self.careerTableView.reloadData()
        }
    }

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
         let models = snapshot.documents.map { (document) -> Career in
           if var model = Career(dictionary: document.data()) {
             model.document = document
             return model
           } else {
             // Don't use fatalError here in a real app.
             fatalError("Unable to initialize type \(Career.self) with dictionary \(document.data())")
           }
         }
         self.careers = models
       }
    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        
        if let user = self.user, user.university.count > 1, user.country.count > 1{
            return Firestore.firestore().collection("countries").document(user.country).collection("universities").document(user.university).collection("careers")
        }
        
        return Firestore.firestore().collection("careers")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
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
    
    func setup() {
        careerTableView.delegate = self
        careerTableView.dataSource = self
    
        query = baseQuery()
    }

    deinit {
      listener?.remove()
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        self.registerUser(user: self.user!)
        
    }

    func registerUser(user: User){
        
        let loader = Loader(forView: self.view)
        loader.showLoading()
        
        Auth.auth().createUser(withEmail: user.email, password: user.password) { authResult, error in
            
            guard let userAuth = authResult?.user, error == nil else {
                self.popupShow(message: error!.localizedDescription)
                loader.hideLoading()
                return
            }
            print("\(userAuth.email!) created")
            
            var updateUser:User = User(dictionary: user.dictionary)!
            updateUser.password = "."
            
            if self.isChangePhoto! {
                
                let imageName = UUID().uuidString
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")

                if let uploadData = self.user?.image!.image?.jpegData(compressionQuality: 0.1) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
                        if let error = error {
                            self.popupShow(message: error.localizedDescription )
                            loader.hideLoading()
                            return
                        }
                        storageRef.downloadURL(completion: { (url, error) in
                            if let error = error {
                                self.popupShow(message: error.localizedDescription )
                                loader.hideLoading()
                                return
                            }
                            guard let photoUrl = url else { return }
                            
                            updateUser.imagePath = photoUrl.absoluteString
                           
                            var ref: DocumentReference? = nil
                            Firestore.firestore().collection("users").document(userAuth.uid).setData(updateUser.dictionary)  { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                    loader.hideLoading()
                                    self.popupShow(message: "Error adding user")
                                } else {
                                    ref = Firestore.firestore().collection("users").document(userAuth.uid)
                                    print("Document added with ID: \(ref!.documentID)")
                                    updateUser.document = ref
                                    loader.hideLoading()
                                    userAuth.sendEmailVerification (completion: { (error) in
                                        // Notify the user that the mail has sent or couldn't because of an error.
                                        if let err = err {
                                            loader.hideLoading()
                                            print("Error adding document: \(err)")
                                        }else{
                                            loader.hideLoading()
                                            let popup =  PopupDialog(title: "Account Created", message: "Verify your email for login in Tasap app")
                                            
                                            let buttonOne = CancelButton(title: "OK") {
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                            
                                            popup.addButton(buttonOne)
                                            self.present(popup, animated: true, completion: nil)
                                        }
                                    })
                                    
                                }
                            }
                            
                        })
                    })
                }
                
            }else {
              
               var ref: DocumentReference? = nil
               Firestore.firestore().collection("users").document(userAuth.uid).setData(updateUser.dictionary)  { err in
                   if let err = err {
                       print("Error adding document: \(err)")
                       loader.hideLoading()
                       self.popupShow(message: "Error adding user")
                   } else {
                       ref = Firestore.firestore().collection("users").document(userAuth.uid)
                       print("Document added with ID: \(ref!.documentID)")
                       updateUser.document = ref
                       loader.hideLoading()
                       userAuth.sendEmailVerification (completion: { (error) in
                           // Notify the user that the mail has sent or couldn't because of an error.
                           if let err = err {
                               loader.hideLoading()
                               print("Error adding document: \(err)")
                           }else{
                               loader.hideLoading()
                               let popup =  PopupDialog(title: "Account Created", message: "Verify your email for login in Tasap app")
                               
                               let buttonOne = CancelButton(title: "OK") {
                                   self.dismiss(animated: true, completion: nil)
                               }
                               
                               popup.addButton(buttonOne)
                               self.present(popup, animated: true, completion: nil)
                           }
                       })
                       
                   }
               }
                
            }
            
            
            
        }
 
    }
    
    func popupShow(message: String){
        
        let popup =  PopupDialog(title: "Error", message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    func popupShow(title:String, message: String){
        
        let popup =  PopupDialog(title: title, message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "tutorDetailSegue" {
            
            let indexPath = sender as! IndexPath
            let career = sections[indexPath.section][indexPath.row]
            let destinationVC = segue.destination as! RegisterTutorDetailViewController
            destinationVC.career = career
            destinationVC.user = self.user
            destinationVC.delegate = self
            
        }

    }
    
}

extension RegisterTutorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      performSegue(withIdentifier: "tutorDetailSegue", sender: indexPath)
    }
    
}

extension RegisterTutorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedFirstLetters[section]
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sortedFirstLetters
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedFirstLetters.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let career = sections[indexPath.section][indexPath.row]
        cell.textLabel?.text = career.name
        cell.detailTextLabel?.text = career.code
        return cell
        
    }
    
}

extension RegisterTutorViewController: RegisterTutorDelegate {
    func fetchUser(user: User) {
        self.user = user
    }

    
}

