//
//  HomeDetailViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/5/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore

class HomeDetailViewController: UIViewController {

    @IBOutlet weak var homeDetailTableView: UITableView!
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Courses ...."
        search.searchBar.sizeToFit()
        search.searchBar.searchBarStyle = .minimal
        search.searchBar.barTintColor = .white
        search.searchBar.set(textColor: .white)
        search.searchBar.setTextField(color: .white)
        search.searchBar.setPlaceholder(textColor: .black)

        return search
    }()
    
    var career: Career?
    
    private var courses: [Course] = [] {
        didSet {
            let coursesSorted = courses.sorted { $0.codeClean.compare($1.codeClean, options: .numeric) == .orderedAscending  }
            courses = coursesSorted
            self.homeDetailTableView.reloadData()
       }
    }
    
    private var filteredCourses = [Course]()
    
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
        let models = snapshot.documents.map { (document) -> Course in
          if var model = Course(dictionary: document.data()) {
            model.document = document
            return model
          } else {
            // Don't use fatalError here in a real app.
            fatalError("Unable to initialize type \(Course.self) with dictionary \(document.data())")
          }
        }
        self.courses = models

      }

    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return career!.document!.reference.collection("courses")
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
        homeDetailTableView.delegate = self
        homeDetailTableView.dataSource = self
    
        query = baseQuery()
        
        navigationItem.searchController = searchController
    }

    deinit {
        listener?.remove()
    }
    
    func filterContentForSearchText(searchText: String){
        
        filteredCourses = courses.filter { (course: Course) -> Bool in
            
            if isSearchBarEmpty() {
                return true
            }else{
                return course.code.lowercased().contains(searchText.lowercased()) || course.name.lowercased().contains(searchText.lowercased())
            }
            
        }
        
        homeDetailTableView.reloadData()
        
    }
    
    func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !isSearchBarEmpty()
    }
    
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
        let indexPath = sender as! IndexPath
        
        let course: Course
        
        if isFiltering() {
            course = filteredCourses[indexPath.row]
        }else {
            course = courses[indexPath.row]
            
        }
        
        let destinationVC = segue.destination as! HomeTutorViewController
        destinationVC.course = course
    }
    
}

extension HomeDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "homeTutorSegue", sender: indexPath)
    }
    
}

extension HomeDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() { return filteredCourses.count }
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let course: Course
        
        if isFiltering() {
            course = filteredCourses[indexPath.row]
        }else {
            course = courses[indexPath.row]
            
        }
        
        cell.textLabel?.text = "\(career!.code) \(course.code)"
        cell.detailTextLabel?.text = course.name
        return cell
        
    }
    
}

extension HomeDetailViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchText: searchBar.text!)
    }
   
}
