//
//  UniversityViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/29/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class UniversityViewController: UIViewController {

    @IBOutlet weak var universityTableView: UITableView!
    @IBOutlet weak var emptyTableMessageView: UIView!
    
    weak var delegate: RegisterDelegate?
    
    var country: Country?
    
    
    private var universities: [University] = [] {
        didSet {
            
            if universities.count > 0 {
                emptyTableMessageView.isHidden = true
            }else{
                emptyTableMessageView.isHidden = false
            }
            
            let coursesSorted = universities.sorted { $0.name < $1.name  }
            universities = coursesSorted
            self.universityTableView.reloadData()
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
        let models = snapshot.documents.map { (document) -> University in
          if var model = University(dictionary: document.data()) {
            model.document = document
            return model
          } else {
            // Don't use fatalError here in a real app.
            fatalError("Unable to initialize type \(University.self) with dictionary \(document.data())")
          }
        }
        self.universities = models

      }

    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("countries").document(country!.document!.documentID).collection("universities")
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
        universityTableView.delegate = self
        universityTableView.dataSource = self
    
        query = baseQuery()
        
    }

    deinit {
        listener?.remove()
    }
}

extension UniversityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell =  tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        let university = universities[indexPath.row]
        self.delegate?.fetchUniversity(university: university)
        self.dismiss(animated: true, completion: nil)
 
    }
    
}

extension UniversityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return universities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
    
        let university = universities[indexPath.row]
        cell.textLabel?.text = university.name
        return cell
        
    }
    
}
