//
//  ProfileViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/9/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import PopupDialog
import Instructions

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var universityImageView: UIImageView!
    
    // MARK: - Public properties
    var university: University?
    var coachMarksController = CoachMarksController()
    
    let profileSectionText = "You are in the profile section, where you can review all your information."
    let avatarText = "That’s your profile picture. You look amazing!"
    let moreButtonText = " Here you can check more of your tutor information."
    let nextButtonText = "Ok!"
    
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coachMarksController.overlay.isUserInteractionEnabled = false
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let userAuth = AuthenticationManager.shared.currentUser {
            if UserDefaultManager.shared.isFirstProfile && userAuth.isTutor{
                startInstructions()
                UserDefaultManager.shared.isFirstProfile = false
            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        coachMarksController.stop(immediately: true)
    }

    func setup(){
        
        //MARK: Init
        
        title = "Profile"
        
        
        //MARK: Instructions Setup
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        /*let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", for: .normal)

        self.coachMarksController.skipView = skipView
        */
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            
            firstLabel.text = userAuth.nameComplete
            emailLabel.text = userAuth.email
            
            if let university = AuthenticationManager.shared.currentUniversity {
                
                self.university = university
                self.universityLabel.text = university.name
                
                let url = URL(string: university.imagePath)
                self.universityImageView.kf.setImage(with: url, placeholder: UIImage(named: "profile_2_background"))
                
            }
            
            
            let url = URL(string: userAuth.imagePath)
            userImageView.kf.setImage(with: url)
            
            userImageView.makeRounded()
            
            if userAuth.isTutor {
                userButton.setTitle("More Info", for: .normal)
            }else{
                userButton.setTitle("I want to be a tutor", for: .normal)
            }

        }
   
    }
    
    func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }

    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        
        if let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
            
            AuthenticationManager.shared.logout() { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let bool):
                    
                    if bool {
                        
                        let ud = UserDefaults.standard
                        ud.removeObject(forKey: "currentUser")
                        
                        loginVC.modalPresentationStyle = .fullScreen
                        strongSelf.present(loginVC, animated: true, completion: nil)
                    }
                    
                case .failure(let error):
                    strongSelf.popupShow(message: error.message)
                }
                
            }

        }
    }
    
    @IBAction func userButtonTapped(_ sender: Any) {
        if let userAuth = AuthenticationManager.shared.currentUser {
            performSegue(withIdentifier: "profileDetailSegue", sender: userAuth)
        }
    }
    
    @IBAction func imageUpdateButtonTapped(_ sender: Any) {
        
        ImagePickerManager().pickImage(self){ image in
            self.userImageView.image = image
            self.uploadImage()
        }

    }
    
    @IBAction func nameUpdateButtonTapped(_ sender: Any) {
        showNameDialog()
    }
    
    func showNameDialog(animated: Bool = true) {

        let loader = Loader(forView: self.view)
        // Create a custom view controller
        let editVC = EditNameViewController(nibName: "EditNameViewController", bundle: nil)
          
        if let userAuth = AuthenticationManager.shared.currentUser {
            editVC.firstName = userAuth.first
            editVC.lastName = userAuth.last
        }

        // Create the dialog
        let popup = PopupDialog(viewController: editVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: false,
                                panGestureDismissal: false)
          
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL", height: 60) {
            loader.hideLoading()
        }

        // Create second button
        let buttonTwo = DefaultButton(title: "UPDATE", height: 60) {
              
            loader.showLoading()
            
            if var userAuth = AuthenticationManager.shared.currentUser {
               
                let first:String = (editVC.firstNameTextField.text?.count ?? 0 > 0 ) ? editVC.firstNameTextField.text! : "unnowed"
                let last:String = (editVC.lastNameTextField.text?.count ?? 0 > 0 ) ? editVC.lastNameTextField.text! : "unnowed"
                
                userAuth.document!.updateData([
                    "first": first,
                    "last": last
                ]){ err in
                    if let err = err {
                        print("Error updating document: \(err)")
                        loader.hideLoading()
                        self.popupShow(message: "Error updating Name")
                    } else {
                        userAuth.first = first
                        userAuth.last = last
                        AuthenticationManager.shared.currentUser = userAuth
                        self.firstLabel.text = userAuth.nameComplete
                        loader.hideLoading()
                        self.popupShow(message: "Name successfully updated")
                    }
                }
                
            }else {
                loader.hideLoading()
                self.popupShow(message: "Error updating Name")
            }
            
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    
    private func uploadImage(){
        
        let loader = Loader(forView: self.view)
        loader.showLoading()
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")

        if let uploadData = userImageView.image?.jpegData(compressionQuality: 0.1) {
            storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
                if let error = error {
                    print(error)
                    loader.hideLoading()
                    return
                }
                storageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                        loader.hideLoading()
                        return
                    }
                    guard let photoUrl = url else { return }
                    
                    if var userAuth = AuthenticationManager.shared.currentUser {
                        userAuth.document!.updateData([
                            "imagePath": photoUrl.absoluteString
                        ]){ err in
                            if let err = err {
                                print("Error updating document: \(err)")
                                loader.hideLoading()
                                self.popupShow(message: "Error updating Image")
                            } else {
                                userAuth.imagePath = photoUrl.absoluteString
                                AuthenticationManager.shared.currentUser = userAuth
                                loader.hideLoading()
                                self.popupShow(message: "Image successfully updated")
                            }
                        }
                    }
                })
            })
        }
    }
    
    func popupShow(message: String){
        
        let popup =  PopupDialog(title: "Info", message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              
        if segue.identifier == "profileDetailSegue" {

            let userAuth = sender as! User
            let destinationVC = segue.destination as! ProfileDetailViewController
            destinationVC.user = userAuth
            destinationVC.university = university

        }

    }
    
}

// MARK: Protocol Conformance | CoachMarksControllerDelegate
// Used for Snapshot testing (i. e. has nothing to do with the example)
extension ProfileViewController: CoachMarksControllerDelegate {
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              configureOrnamentsOfOverlay overlay: UIView) {
        snapshotDelegate?.coachMarksController(coachMarksController,
                                               configureOrnamentsOfOverlay: overlay)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willShow coachMark: inout CoachMark,
                              beforeChanging change: ConfigurationChange,
                              at index: Int) {
        snapshotDelegate?.coachMarksController(coachMarksController, willShow: &coachMark,
                                               beforeChanging: change,
                                               at: index)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didShow coachMark: CoachMark,
                              afterChanging change: ConfigurationChange,
                              at index: Int) {
        snapshotDelegate?.coachMarksController(coachMarksController, didShow: coachMark,
                                               afterChanging: change,
                                               at: index)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willHide coachMark: CoachMark,
                              at index: Int) {
        snapshotDelegate?.coachMarksController(coachMarksController, willHide: coachMark,
                                               at: index)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didHide coachMark: CoachMark,
                              at index: Int) {
        snapshotDelegate?.coachMarksController(coachMarksController, didHide: coachMark,
                                               at: index)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didEndShowingBySkipping skipped: Bool) {
        snapshotDelegate?.coachMarksController(coachMarksController,
                                               didEndShowingBySkipping: skipped)
    }

    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController,
                                at index: Int) -> Bool {
        return true
    }
    
}

extension ProfileViewController: CoachMarksControllerDataSource {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        3
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(
                for: self.navigationController?.navigationBar,
                cutoutPathMaker: { (frame: CGRect) -> UIBezierPath in
                    // This will make a cutoutPath matching the shape of
                    // the component (no padding, no rounded corners).
                    return UIBezierPath(rect: frame)
                }
            )
        case 1:
            return coachMarksController.helper.makeCoachMark(for: self.userImageView)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: self.userButton)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
        
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
          
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )

        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = self.profileSectionText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.avatarText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.moreButtonText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
            coachViews.bodyView.nextControl?.addTarget(self, action: #selector(moreInfo), for: .touchUpInside)
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)

    }

    @objc func moreInfo(){
        if let userAuth = AuthenticationManager.shared.currentUser {
            performSegue(withIdentifier: "profileDetailSegue", sender: userAuth)
        }
    }
    
}

