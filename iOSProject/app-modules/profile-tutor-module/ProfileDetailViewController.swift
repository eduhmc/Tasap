//
//  ProfileDetailViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/24/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import PopupDialog
import FirebaseFirestore
import Instructions

class ProfileDetailViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    
    // MARK: - Public properties
    var userAuth: User {
        return AuthenticationManager.shared.currentUser!
    }
    var universityAuth: University {
        return AuthenticationManager.shared.currentUniversity!
    }
    
    var coachMarksController = CoachMarksController()
    
    let profileSectionText = "You are in the Profile Detail section, where you can review all your information as a tutor."
    let priceText = "That’s your price per hour. Students will see this when looking for tutors."
    let reputationText = "That’s your rating as a tutor, strive for five stars!"
    let reviewText = "Those are your reviews, strive for good comments!"
    let nextButtonText = "Ok!"
    
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    private var reviews: [Review] = [] {
        didSet {
            let coursesSorted = reviews.sorted { $0.review < $1.review  }
            reviews = coursesSorted
            self.reviewTableView.reloadData()
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
        let models = snapshot.documents.map { (document) -> Review in
          if var model = Review(dictionary: document.data()) {
            model.document = document.reference
            return model
          } else {
            // Don't use fatalError here in a real app.
            fatalError("Unable to initialize type \(Review.self) with dictionary \(document.data())")
          }
        }
        self.reviews = models
      }

    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return userAuth.document!.collection("reviews")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        coachMarksController.overlay.isUserInteractionEnabled = false
        setup()
        observeQuery()
    }
    
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)

          if UserDefaultManager.shared.isFirstProfileDetail {
              startInstructions()
              UserDefaultManager.shared.isFirstProfileDetail = false
          }
    
      }
       
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
        coachMarksController.stop(immediately: true)
    }
    
    func setup(){
        
        //MARK: Init
        title = "Profile Detail"
        
        //MARK: Instructions Setup
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self

        
        firstNameLabel.text = "\(userAuth.first) \(userAuth.last)"
        emailLabel.text = userAuth.email
        priceLabel.text = "$\(userAuth.price)"
        ratingLabel.text = String(format: "%.1f", userAuth.ratingAverage)
        descriptionLabel.text = userAuth.description
        
        let url = URL(string: userAuth.imagePath)
        userImageView.kf.setImage(with: url)
        
        userImageView.makeRounded()
        
        let urlBack = URL(string: universityAuth.imagePath)
        backgroundImageView.kf.setImage(with: urlBack)
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        query = baseQuery()
    }
    
    deinit {
        listener?.remove()
    }
    
    func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }
    
    
    @IBAction func priceUpdateButtonTapped(_ sender: Any) {
        
        self.showPriceDialog(animated: true)
    }
    
    @IBAction func descriptionUpdateButtonTapped(_ sender: Any) {
        
        self.showDescriptionDialog(animated: true)
    }
    
    func showPriceDialog(animated: Bool = true) {

        let loader = Loader(forView: self.view)
        // Create a custom view controller
        let editVC = EditViewController(nibName: "EditViewController", bundle: nil)
        
        editVC.textTitle = "Price"
        editVC.textComment = userAuth.price
        editVC.typeTextField = .numeric

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
            
            let price:String = (editVC.commentTextField.text?.count ?? 0 > 0 ) ? editVC.commentTextField.text! : "0.0"
            
            self.userAuth.document!.updateData([
                "price": price
            ]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    loader.hideLoading()
                    self.popupShow(message: "Error updating Price")
                } else {
                    AuthenticationManager.shared.currentUser!.price = price
                    self.priceLabel.text = "$\(price)"
                    loader.hideLoading()
                    self.popupShow(message: "Price successfully updated")
                }
            }
  
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    func showDescriptionDialog(animated: Bool = true) {

        let loader = Loader(forView: self.view)
        // Create a custom view controller
        let editVC = EditDescriptionViewController(nibName: "EditDescriptionViewController", bundle: nil)
          
        editVC.textTitle = "Description"
        editVC.textComment = userAuth.description

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
            
            let description:String = (editVC.descriptionTextView.text.count > 0 ) ? editVC.descriptionTextView.text! : "."
            
            self.userAuth.document!.updateData([
                "description": description
            ]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    loader.hideLoading()
                    self.popupShow(message: "Error updating Description")
                } else {
                    AuthenticationManager.shared.currentUser!.description = description
                    self.descriptionLabel.text = description
                    loader.hideLoading()
                    self.popupShow(message: "Description successfully updated")
                }
            }
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    func popupShow(message: String){
        
        let popup =  PopupDialog(title: "Info", message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
}

extension ProfileDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
}

extension ProfileDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell
        let review = reviews[indexPath.row]
        cell.populate(review: review)
        return cell
        
    }
    
}


// MARK: Protocol Conformance | CoachMarksControllerDelegate
// Used for Snapshot testing (i. e. has nothing to do with the example)
extension ProfileDetailViewController: CoachMarksControllerDelegate {
    
    
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

extension ProfileDetailViewController: CoachMarksControllerDataSource {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        4
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
            return coachMarksController.helper.makeCoachMark(for: self.priceLabel)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: self.ratingLabel)
        case 3:
            return coachMarksController.helper.makeCoachMark(for: self.reviewTableView)
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
            coachViews.bodyView.hintLabel.text = self.priceText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.reputationText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 3:
            coachViews.bodyView.hintLabel.text = self.reviewText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)

    }
    
}
