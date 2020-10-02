//
//  ProfileHamburgerView.swift
//  iOSProject
//
//  Created by everis on 8/18/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit

class ProfileHamburgerView: UIViewController, ProfileHamburgerPresenterToViewProtocol {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var tutorDetailButton: UIButton!
    @IBOutlet weak var courseListButton: UIButton!
    @IBOutlet weak var updateCourseListButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var presenter: ProfileHamburgerViewToPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.loadData()
    }
    
    func showData(model: ProfileHamburgerModel) {
        
        let url = URL(string: AuthenticationManager.shared.currentUser!.imagePath)
        userImageView.kf.setImage(with: url)
        userImageView.makeRounded()
        
        nameLabel.text = "\(model.userAuth.first) \(model.userAuth.last)"
        
        calendarButton.isHidden = model.isHiddenCalendar
        tutorDetailButton.isHidden = model.isHiddenTutorDetail
        //courseListButton.isHidden = model.isHiddenCourseList
        updateCourseListButton.isHidden = model.isHiddenUpdateCourseList
    }
    
    @IBAction func calendarButtonTapped(_ sender: Any) {
        presenter?.showCalendarModule()
    }
    
    @IBAction func TutorDetailButtonTapped(_ sender: Any) {
        presenter?.showProfileDetailModule()
    }
    
    @IBAction func CourseListButtonTapped(_ sender: Any) {
        presenter?.showCoursesListModule()
    }
    
    @IBAction func UpdateCourseListTapped(_ sender: Any) {
        presenter?.showUpdateCoursesListModule()
    }
    
    @IBAction func LogoutButtonTapped(_ sender: Any) {
        presenter?.showLoginModule()
    }
    
}
