//
//  MyCoursesView.swift
//  iOSProject
//
//  Created by everis on 9/21/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class MyCoursesView: UIViewController, MyCoursesPresenterToViewProtocol{
    
    @IBOutlet weak var coursesTableView: UITableView!
    
    var courses: [Course] = []
    var presenter: MyCoursesViewToPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup(){
        title = "My Courses"
        navigationItem.largeTitleDisplayMode = .never
        presenter?.loadCourses()
    }
    
    func showCourses(courses: [Course]) {
        self.courses = courses
        self.coursesTableView.reloadData()
    }

}

extension MyCoursesView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}

extension MyCoursesView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCoursesCell",
                                                 for: indexPath) as! MyCoursesCell
        let course = courses[indexPath.row]
        cell.setup(course: course)
        return cell
    }
 
}
