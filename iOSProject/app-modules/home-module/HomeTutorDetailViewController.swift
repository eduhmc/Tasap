//
//  HomeTutorDetailViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/17/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import PopupDialog
import FirebaseFirestore

class HomeTutorDetailViewController: UIViewController {

     
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var calendarButton: UIBarButtonItem!
    @IBOutlet weak var chatButton: UIBarButtonItem!
    
    @IBOutlet weak var reviewTableView: UITableView!
    
    @IBOutlet weak var reserveView: DesignableView!
    
    
    var tutor: User?
    var course: Course?
    var review: Review?
    
    var isRateTutor: Bool = false
    
    private var reviews: [Review] = [] {
        didSet {
            let reviewsSorted = reviews.sorted { $0.review < $1.review  }
            reviews = reviewsSorted
            self.reviewTableView.reloadData()
            self.updateReview()
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
        return tutor!.document!.collection("reviews")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
    
    func setup(){
        
        if let tutor = self.tutor {
           
            firstNameLabel.text = "\(tutor.first) \(tutor.last)"
            emailLabel.text = tutor.email
            priceLabel.text = "$\(tutor.price)"
            ratingLabel.text =  String(format: "%.1f", tutor.ratingAverage)
            descriptionLabel.text = tutor.description
            
            let url = URL(string: tutor.imagePath)
            userImageView.kf.setImage(with: url)
            
            userImageView.makeRounded()
            
            reviewTableView.delegate = self
            reviewTableView.dataSource = self
            query = baseQuery()
            
            if let userAuth = AuthenticationManager.shared.currentUser ,userAuth.document?.documentID == tutor.document?.documentID  {
                rateButton.isHidden = true
                calendarButton.isEnabled = false
                chatButton.isEnabled = false
                reserveView.isHidden = true
            }else{
                rateButton.isHidden = false
                calendarButton.isEnabled = true
                chatButton.isEnabled = true
                reserveView.isHidden = false
            }
            
        }
 
    }
    
    func updateReview(){
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            let rates = reviews.filter { $0.author == userAuth.document?.documentID }
            if rates.count > 0 {
                isRateTutor = true
                review = rates[0]
                rateButton.setTitle("Edit Review", for: .normal)
            }else{
                rateButton.setTitle("Rate Tutor", for: .normal)
                isRateTutor = false
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    @IBAction func ratingButtonTaped(_ sender: Any) {
       
        if isRateTutor {
            showEditReviewDialog()
        }else{
            showAddReviewDialog()
        }
        
    }
    
    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard.init(name: "Calendar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CalendarView") as! CalendarView
        
        let calendarModel = CalendarModel(isOnlyView: true, user: tutor, course: course)
        
        CalendarRouter.createCalendarModule(view: vc, model: calendarModel)
        vc.modalPresentationStyle = .automatic
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func reserveButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "Calendar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CalendarView") as! CalendarView
        
        let calendarModel = CalendarModel(isOnlyView: true, user: tutor, course: course)
        
        CalendarRouter.createCalendarModule(view: vc, model: calendarModel)
        vc.modalPresentationStyle = .automatic
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "chatSegue", sender: tutor)
    }
    
    
    func showAddReviewDialog(animated: Bool = true) {

        let loader = Loader(forView: self.view)
        
        // Create a custom view controller
        let ratingVC = RatingViewController(nibName: "RatingViewController", bundle: nil)
        
        ratingVC.textSubtitle = "\(tutor!.first) \(tutor!.last)"

        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: false,
                                panGestureDismissal: false)
        
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL", height: 60) {
            loader.hideLoading()
        }

        // Create second button
        let buttonTwo = DefaultButton(title: "RATE", height: 60) {
            
            loader.showLoading()
            
            if let userAuth = AuthenticationManager.shared.currentUser {
                    
                let comment = (ratingVC.commentTextField.text?.count ?? 0 > 0 ) ? ratingVC.commentTextField.text : "."
                let reviewRating = Int(ratingVC.cosmosStarRating.rating.rounded())
                let course = self.course!.name
                let date = Date().description(with: .current)
                
                let review = Review(author: userAuth.document!.documentID, comment: comment!, review: reviewRating, course: course, date: date)
                
                var ref: DocumentReference? = nil
                ref = self.tutor!.document!.collection("reviews").addDocument(data: review.dictionary)  { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        loader.hideLoading()
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        
                        let newNumber = Double(self.tutor!.ratingNumber) + 1.0
                        let newRating = ((self.tutor!.ratingAverage * Double(self.tutor!.ratingNumber)) + Double(review.review)) / newNumber
                        
                        self.tutor?.document?.updateData([
                            "ratingAverage": newRating,
                            "ratingNumber": newNumber
                        ]){ err in
                            if let err = err {
                                print("Error updating document: \(err)")
                                loader.hideLoading()
                            } else {
                                print("Document successfully updated")
                                self.tutor?.ratingNumber = Int(newNumber)
                                self.tutor?.ratingAverage = newRating
                                
                                self.ratingLabel.text = String(format: "%.1f", newRating)
                                loader.hideLoading()
                            }
                        }
   
                    }
                }
                  
            }
            
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    func showEditReviewDialog(animated: Bool = true) {
        
        let loader = Loader(forView: self.view)
        
        // Create a custom view controller
        let ratingVC = RatingViewController(nibName: "RatingViewController", bundle: nil)
        
        ratingVC.textSubtitle = "\(tutor!.first) \(tutor!.last)"
        
        if let review = self.review {
            ratingVC.textComment = review.comment
            ratingVC.rateNumber = review.review
        }
        

        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: false,
                                panGestureDismissal: false)
        
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL", height: 60) {
            loader.hideLoading()
        }

        // Create second button
        let buttonTwo = DefaultButton(title: "RATE", height: 60) {
        
            loader.showLoading()
            
            let comment = (ratingVC.commentTextField.text?.count ?? 0 > 0 ) ? ratingVC.commentTextField.text : "."
            let reviewRating = Int(ratingVC.cosmosStarRating.rating.rounded())
            let reviewRatingOld = self.review?.review
            let date = Date().description(with: .current)
            
            self.review?.document?.updateData([
                "comment": comment!,
                "date": date,
                "review":reviewRating
            ]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    loader.hideLoading()
                } else {
                    print("Document successfully updated")
                    
                    let newNumber = Double(self.tutor!.ratingNumber)
                    let newRating = (((self.tutor!.ratingAverage * Double(self.tutor!.ratingNumber)) - Double(reviewRatingOld!)) + Double(reviewRating)) / newNumber
                    
                    self.tutor?.document?.updateData([
                        "ratingAverage": newRating
                    ]){ err in
                        if let err = err {
                            print("Error updating document: \(err)")
                            loader.hideLoading()
                        } else {
                            print("Document successfully updated")
                            self.tutor?.ratingAverage = newRating
                            self.ratingLabel.text = String(format: "%.1f", newRating)
                            loader.hideLoading()
                        }
                    }
                    
                    
                }
            }
            
        }
        
        // Create thirt button
        let buttonThree = DestructiveButton(title: "DELETE") {
            
            loader.showLoading()
            
            let reviewRatingOld = self.review?.review

            self.review?.document?.delete(){ err in
                if let err = err {
                    print("Error removing document: \(err)")
                    loader.hideLoading()
                } else {
                    print("Document successfully removed!")
                    
                    let newNumber = Double(self.tutor!.ratingNumber) - 1
                    let newRating = ((self.tutor!.ratingAverage * Double(self.tutor!.ratingNumber)) - Double(reviewRatingOld!)) / newNumber
                    
                    self.tutor?.document?.updateData([
                        "ratingAverage": newRating
                    ]){ err in
                        if let err = err {
                            print("Error updating document: \(err)")
                            loader.hideLoading()
                        } else {
                            print("Document successfully updated")
                            
                            self.tutor?.ratingAverage = newRating
                            self.ratingLabel.text = String(format: "%.1f", newRating)
                            loader.hideLoading()
                        }
                    }
  
                }
            }
            
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo,buttonThree])

        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /*if segue.identifier == "calendarSegue" {
            let tutor = sender as! User
            let destinationVC = segue.destination as! CalendarView
            destinationVC.user = tutor
            destinationVC.course = course
            destinationVC.isOnlyView = true
        }*/
        
        if segue.identifier == "chatSegue" {
            
            let destinationVC = segue.destination as! ChatViewController
            
            if let tutor  = self.tutor {
                destinationVC.user2Name = "\(tutor.first) \(tutor.last)"
                destinationVC.user2UID = tutor.document?.documentID
                destinationVC.user2ImgUrl = tutor.imagePath
                destinationVC.user2FcmToken = tutor.fcmToken
            }
            
        }
           
    }

}

extension HomeTutorDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
}

extension HomeTutorDetailViewController: UITableViewDataSource {
    
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
