//
//  HomeController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/2/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PopupDialog
import Instructions

class HomeView: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var universityLabel: UILabel!
    
    @IBOutlet weak var findTutorView: UIView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var meetingView: UIView!
    
    // MARK: - Public properties
    public var user: User?
    
    var coachMarksController = CoachMarksController()
    
    let homeSectionText = "You are in the Home section"
    let findTutorText = "In this section you can find the best tutors!"
    let chatText = "In this section you will find all the conversations you start"
    let requestText = "In this section you will see the requests that you send or receive"
    let meetingText = "In this section you will see all the accepted requests"
    let nextButtonText = "OK!"
    
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Instructions Setup
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        if UserDefaultManager.shared.isFirstHome {
            startInstructions()
            UserDefaultManager.shared.isFirstHome = false
        }
        
        if let userAuth = AuthenticationManager.shared.currentUser{
           
            nameLabel.text = "Hello \(userAuth.first)"
            
            UniversityAPI.shared.get(documentID: userAuth.university) { result in
                switch result {
                    case .success(let document):
                    
                        if let university = University(dictionary: document.data()!){
                            
                            AuthenticationManager.shared.currentUniversity = university
                            self.universityLabel.text = university.name
                            
                        }
                    
                    case .failure(let error):
                        print(error)
                        self.universityLabel.text = ""
                        print("Document does not exist")
                }
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coachMarksController.overlay.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        coachMarksController.stop(immediately: true)
    }

    
    @IBAction func tutorButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "careerSegue", sender: nil)
    }
    
    @IBAction func otherButtonTapped(_ sender: Any) {
       performSegue(withIdentifier: "chatSegue", sender: nil)
    }
    
    @IBAction func requestButtonTapped(_ sender: Any) {
  
        let storyboard = UIStoryboard.init(name: "Request", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RequestView") as! RequestView
        
        RequestRouter.createRequestModule(view: vc, state: "PENDING")
        vc.modalPresentationStyle = .automatic
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func meetingButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "Request", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RequestView") as! RequestView
        
        RequestRouter.createRequestModule(view: vc, state: "ACCEPTED")
        vc.modalPresentationStyle = .automatic
        self.navigationController?.pushViewController(vc, animated: true)
  
    }
    
    func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "careerSegue" {
            
            let destinationVC = segue.destination as! HomeViewController
            destinationVC.user = self.user
            
        }
   
    }
    
}

// MARK: Protocol Conformance | CoachMarksControllerDelegate
// Used for Snapshot testing (i. e. has nothing to do with the example)
extension HomeView: CoachMarksControllerDelegate {
    
    
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

extension HomeView: CoachMarksControllerDataSource {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        5
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
            return coachMarksController.helper.makeCoachMark(for: self.findTutorView)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: self.chatView)
        case 3:
            return coachMarksController.helper.makeCoachMark(for: self.requestView)
        case 4:
            return coachMarksController.helper.makeCoachMark(for: self.meetingView)
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
            coachViews.bodyView.hintLabel.text = self.homeSectionText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.findTutorText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.chatText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 3:
            coachViews.bodyView.hintLabel.text = self.requestText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 4:
            coachViews.bodyView.hintLabel.text = self.meetingText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)

    }
    
}
