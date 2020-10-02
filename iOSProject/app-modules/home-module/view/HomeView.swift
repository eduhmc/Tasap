//
//  HomeController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/2/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PopupDialog
import Instructions

class HomeView: UIViewController, HomePresenterToViewProtocol {
    
    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var universityLabel: UILabel!
    
    @IBOutlet weak var findTutorView: UIView!
    @IBOutlet weak var requestView: UIView!
    
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var chatImageView: UIImageView!
    
    @IBOutlet weak var meetingView: UIView!
    @IBOutlet weak var meetingImageView: UIImageView!
    
    
    
    // MARK: - Public properties
    var model: HomeModel?
    var presenter: HomeViewToPresenterProtocol?
    var coachMarksController = CoachMarksController()
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        presenter?.loadInformation(view: self)
        
        navigationItem.largeTitleDisplayMode = .always
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coachMarksController.overlay.isUserInteractionEnabled = false
        presenter?.loadNumberOfRequest()
        presenter?.loadNumberOfChats()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coachMarksController.stop(immediately: true)
    }
    
    func showInformation(model: HomeModel) {
        
        if let userAuth = AuthenticationManager.shared.currentUser{
            self.model = model
            nameLabel.text = "Hello \(userAuth.first)"
            universityLabel.text = model.university.name
            
            if model.isFirstHome {
                
                let popup = PopupDialog(title: "Welcome to Tasap App", message: "Would you like to start the tutorial ?")
                
                // Create first button
                let buttonOne = DestructiveButton(title: "No thanks", height: 60) {
                   
                }

                // Create second button
                let buttonTwo = DefaultButton(title: "Let's go", height: 60) {
                    self.startInstructions()
                    
                }
                popup.addButtons([buttonOne, buttonTwo])
                    
                self.present(popup, animated: true, completion: nil)
                
                self.model!.isFirstHome = false
                
            }
            
        }
        
    }
    
    func showNumberOfRequest(number: Int) {
        meetingImageView.clipsToBounds = false
        meetingImageView.badge(text: number == 0 ? nil : number.description)
    }
    
    func showNumberOfChats(number: Int) {
        chatImageView.clipsToBounds = false
        chatImageView.badge(text: number == 0 ? nil : number.description)
    }

    @IBAction func tutorButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "careerSegue", sender: nil)
    }
    
    @IBAction func otherButtonTapped(_ sender: Any) {
        presenter?.showChatModule(fromView: self)
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
    
    @objc func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "careerSegue" {
            
            let destinationVC = segue.destination as! HomeViewController
            destinationVC.user = AuthenticationManager.shared.currentUser!
            
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
            coachViews.bodyView.hintLabel.text = self.model!.homeSectionText
            coachViews.bodyView.nextLabel.text = self.model!.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.model!.findTutorText
            coachViews.bodyView.nextLabel.text = self.model!.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.model!.chatText
            coachViews.bodyView.nextLabel.text = self.model!.nextButtonText
        case 3:
            coachViews.bodyView.hintLabel.text = self.model!.requestText
            coachViews.bodyView.nextLabel.text = self.model!.nextButtonText
        case 4:
            coachViews.bodyView.hintLabel.text = self.model!.meetingText
            coachViews.bodyView.nextLabel.text = self.model!.nextButtonText
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)

    }
    
}
