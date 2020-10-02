//
//  HomeViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/2/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var homeTableView: UITableView!
    
    public var user: User?
    
    private var sortedFirstLetters: [String] = []
    private var sections: [[Career]] = [[]]
    
    private var careers: [Career] = [] {
        didSet {
            
            /*for career in careers {
                
                career.document?.reference.collection("courses")
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                               
                                document.reference.updateData([
                                    "id": document.documentID
                                ])
                            }
                        }
                }
                
            }*/

            let firstLetters = careers.map { $0.nameFirstLetter }
            let uniqueFirstLetters = Array(Set(firstLetters))
            
            sortedFirstLetters = uniqueFirstLetters.sorted()
            sections = sortedFirstLetters.map { firstLetter in
                return careers
                    .filter { $0.nameFirstLetter == firstLetter }
                    .sorted { $0.name < $1.name }
            }
            
            self.homeTableView.reloadData()
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
        
        if let user = self.user, user.university.count > 1 {
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
        homeTableView.delegate = self
        homeTableView.dataSource = self
 
        query = baseQuery()
    }

    deinit {
      listener?.remove()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = sender as! IndexPath
        let career = sections[indexPath.section][indexPath.row]
        let destinationVC = segue.destination as! HomeDetailViewController
        destinationVC.career = career
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      performSegue(withIdentifier: "homeDetailSegue", sender: indexPath)
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell",
                                                 for: indexPath) as! HomeTableViewCell
        let career = sections[indexPath.section][indexPath.row]
        cell.populate(career: career)
        return cell
        
    }
    
}

