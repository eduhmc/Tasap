//
//  UpdateCoursesViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/26/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore


class UpdateCoursesViewController: UIViewController {

    @IBOutlet weak var coursesTableView: UITableView!
    
    weak var delegate: UpdateCareerDelegate?
    
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
    
    var user: User?
    var career: Career?
    
    private var courses: [Course] = [] {
        didSet {
            let coursesSorted = courses.sorted { $0.codeClean.compare($1.codeClean, options: .numeric) == .orderedAscending  }
            courses = coursesSorted
            self.coursesTableView.reloadData()
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
        coursesTableView.delegate = self
        coursesTableView.dataSource = self
    
        query = baseQuery()
        
        self.navigationItem.searchController = searchController
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "<Back", style: .done, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.delegate?.fetchUser(user: self.user!)
        _ = navigationController?.popViewController(animated: true)
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
        
        coursesTableView.reloadData()
        
    }
    
    func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !isSearchBarEmpty()
    }
    
}

extension UpdateCoursesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell =  tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        let course: Course
        
        if isFiltering() {
            course = filteredCourses[indexPath.row]
        }else {
            course = courses[indexPath.row]
            
        }

        if !self.user!.courses.contains(course.document!.documentID) {
            self.user?.courses.append(course.document!.documentID)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell =  tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        
        let course: Course
        
        if isFiltering() {
            course = filteredCourses[indexPath.row]
        }else {
            course = courses[indexPath.row]
        }
        
        if self.user!.courses.contains(course.document!.documentID) {
            if let index  = self.user?.courses.index(of: course.document!.documentID) {
                self.user?.courses.remove(at: index)
            }
        }
        
    }
    
}

extension UpdateCoursesViewController: UITableViewDataSource {
    
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
        
        if self.user!.courses.contains(course.document!.documentID) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        }
        
        return cell
        
    }
    
}

extension UpdateCoursesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchText: searchBar.text!)
    }
   
}
