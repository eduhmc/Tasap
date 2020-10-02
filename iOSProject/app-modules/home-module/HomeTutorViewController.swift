//
//  HomeTutorViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/9/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class HomeTutorViewController: UIViewController {

    @IBOutlet weak var homeTutorTableView: UITableView!
    @IBOutlet weak var emptyTableMessageView: UIView!
    
    var course: Course?
    
    private var sortedFirstLetters: [String] = []
    private var sections: [[User]] = [[]]
       
    private var users: [User] = [] {
        didSet {
            
            if users.count > 0 {
                emptyTableMessageView.isHidden = true
            }else{
                emptyTableMessageView.isHidden = false
            }
            
            let ratingNumbers = users.map { "\(Int($0.ratingAverage.rounded()))" }
            let uniqueRatingNumbers = Array(Set(ratingNumbers))
           
            sortedFirstLetters = uniqueRatingNumbers.sorted{ $1 < $0  }
            sections = sortedFirstLetters.map { ratingNumber in
                return users
                    .filter { "\(Int($0.ratingAverage.rounded()))" == ratingNumber }
                    .sorted { $0.last < $1.last }
           }
           
           self.homeTutorTableView.reloadData()
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
        let models = snapshot.documents.map { (document) -> User in
          if var model = User(dictionary: document.data()) {
            model.document = document.reference
            return model
          } else {
            // Don't use fatalError here in a real app.
            fatalError("Unable to initialize type \(User.self) with dictionary \(document.data())")
          }
        }
        self.users = models

      }

    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        
        return Firestore.firestore().collection("users").whereField("courses", arrayContains: course!.document!.documentID)
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
        homeTutorTableView.delegate = self
        homeTutorTableView.dataSource = self
    
        query = baseQuery()
    }

    deinit {
        listener?.remove()
    }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = sender as! IndexPath
        let user = sections[indexPath.section][indexPath.row]
        let destinationVC = segue.destination as! HomeTutorDetailViewController
        destinationVC.tutor = user
        destinationVC.course = course
           
    }

}

extension HomeTutorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "tutorDetailSegue", sender: indexPath)
    }
    
}

extension HomeTutorViewController: UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTutorTableViewCell",
                                                 for: indexPath) as! HomeTutorTableViewCell
        let user = sections[indexPath.section][indexPath.row]
        cell.populate(user: user)
        return cell
        
    }
    
}
