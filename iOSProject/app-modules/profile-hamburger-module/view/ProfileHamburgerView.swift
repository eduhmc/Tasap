//
//  ProfileHamburgerView.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/18/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import Instructions

class ProfileHamburgerView: UIViewController, ProfileHamburgerPresenterToViewProtocol {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var tutorDetailButton: UIButton!
    @IBOutlet weak var courseListButton: UIButton!
    @IBOutlet weak var updateCourseListButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var presenter: ProfileHamburgerViewToPresenterProtocol?
    var coachMarksController = CoachMarksController()
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    var model:ProfileHamburgerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.loadData()
        
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter?.loadData()
        
        if !UserDefaultManager.shared.isFirstProfile && UserDefaultManager.shared.isFirstHamburgerProfile && !sideMenuController!.isMenuRevealed {
            startInstructions()
            UserDefaultManager.shared.isFirstHamburgerProfile = false
        }
        
    }
    func showData(model: ProfileHamburgerModel) {
        self.model = model
        
        if model.userAuth.imagePath.count > 0 {
            let url = URL(string: AuthenticationManager.shared.currentUser!.imagePath)
            userImageView.kf.setImage(with: url)
            userImageView.makeRounded()
        }else{
            userImageView.setImageForName(model.userAuth.first, circular: true, textAttributes: nil)
        }
   
        nameLabel.text = "\(model.userAuth.first) \(model.userAuth.last)"
        
        calendarButton.isHidden = model.isHiddenCalendar
        tutorDetailButton.isHidden = model.isHiddenTutorDetail
        courseListButton.isHidden = model.isHiddenCourseList
        
        updateCourseListButton.setTitle(model.updateCourseListButtonText, for: .normal)
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
