//
//  CountryViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/10/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CountryViewController: UIViewController {

    @IBOutlet weak var countryTableView: UITableView!
    
    weak var delegate: RegisterDelegate?
    
    private var countries: [Country] = [] {
        didSet {
            let countriesSorted = countries.sorted { $0.name < $1.name  }
            countries = countriesSorted
            self.countryTableView.reloadData()
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
        let models = snapshot.documents.map { (document) -> Country in
          if var model = Country(dictionary: document.data()) {
            model.document = document
            return model
          } else {
            // Don't use fatalError here in a real app.
            fatalError("Unable to initialize type \(University.self) with dictionary \(document.data())")
          }
        }
        self.countries = models

      }

    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("countries")
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
        countryTableView.delegate = self
        countryTableView.dataSource = self
    
        query = baseQuery()
        
    }

    deinit {
        listener?.remove()
    }
}

extension CountryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell =  tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        let country = countries[indexPath.row]
        self.delegate?.fetchCountry(country: country)
        self.dismiss(animated: true, completion: nil)
 
    }
    
}

extension CountryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
    
        let country = countries[indexPath.row]
        cell.textLabel?.text = country.name
        return cell
        
    }
    
}
