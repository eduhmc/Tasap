//
//  UpdateCareerView.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/26/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PopupDialog
import FirebaseStorage
import Instructions

protocol UpdateCareerDelegate: class {
    func fetchUser(user: User)
}

class UpdateCareerView: UIViewController {
    
    @IBOutlet weak var careerTableView: UITableView!
    
    var coachMarksController = CoachMarksController()
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    var updateCareerSectionText = "In this section you can update the courses you want to tutor"
    let nextButtonText = "Ok!"
    
    var user: User?
    
    var isModifyCourses = false
    
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
        
        if let userAuth = AuthenticationManager.shared.currentUser{
            return Firestore.firestore().collection("countries").document(userAuth.country).collection("universities").document(userAuth.university).collection("careers")
        }
        
        return Firestore.firestore().collection("careers")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
        self.user = AuthenticationManager.shared.currentUser!
        let backButton = UIBarButtonItem(title: "<Back", style: .plain, target: self, action: #selector(goBack(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.setNeedsStatusBarAppearanceUpdate()
      observeQuery()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UserDefaultManager.shared.isFirstUpdateCareer {
            startInstructions()
            UserDefaultManager.shared.isFirstUpdateCareer = false
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       stopObserving()
     }
    

    func setup() {
        
        title = "Careers"
        careerTableView.delegate = self
        careerTableView.dataSource = self
        query = baseQuery()
        
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
    }
    
    @objc func goBack(sender: UIBarButtonItem)
    {
        if isModifyCourses {
     
            let popup =  PopupDialog(title: "Info", message: "If you return to the profile, the courses you have modified will be lost.")
            
            let buttonOne = DefaultButton(title: "OK") {
                print("You ok popup tapped")
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            let buttonTwo = DestructiveButton(title: "Cancel"){
                
            }
            
            popup.addButton(buttonOne)
            popup.addButton(buttonTwo)
            self.present(popup, animated: true, completion: nil)
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }

    deinit {
      listener?.remove()
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        
        self.updateUser(user: self.user!)
    }

    func updateUser(user: User){
        
        let loader = Loader(forView: self.view)
        loader.showLoading()
        
        user.document?.updateData([
            "courses": user.courses
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                loader.hideLoading()
                self.popupShow(message: "Error updating Courses")
            } else {
                AuthenticationManager.shared.currentUser = user
                loader.hideLoading()
                self.popupShow(message: "Courses successfully updated")
            }
        }
        
    }
    
    func popupShow(message: String){
        
        let popup =  PopupDialog(title: "Info", message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "tutorDetailSegue" {
            
            let indexPath = sender as! IndexPath
            let career = sections[indexPath.section][indexPath.row]
            let destinationVC = segue.destination as! UpdateCoursesViewController
            destinationVC.career = career
            destinationVC.user = self.user
            destinationVC.delegate = self
            
        }

    }
    
}

extension UpdateCareerView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      performSegue(withIdentifier: "tutorDetailSegue", sender: indexPath)
    }
    
}

extension UpdateCareerView: UITableViewDataSource {
    
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

extension UpdateCareerView: UpdateCareerDelegate {
    func fetchUser(user: User) {
        isModifyCourses = true
        self.user = user
    }
    
    
}
