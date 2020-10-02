//
//  CalendarViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 5/11/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import CalendarKit
import DateToolsSwift
import FirebaseFirestore
import PopupDialog
import Instructions

class CalendarView : DayViewController {

    // MARK: - Public properties
    var coachMarksController = CoachMarksController()
    
    let calendarSectionText = "You are in the calendar section, where you can add your availability."
    let nextButtonText = "Ok!"
    
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    var user:User?
    var course:Course?
    
    var isOnlyView = true
    
    var events = [Eveent]() {
        didSet{
            reloadData()
        }
    }
    
    var colors = [UIColor.blue,
    UIColor.yellow,
    UIColor.green,
    UIColor.red]

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
         let models = snapshot.documents.map { (document) -> Eveent in
           if var model = Eveent(dictionary: document.data()) {
             model.document = document
             return model
           } else {
             // Don't use fatalError here in a real app.
             fatalError("Unable to initialize type \(Eveent.self) with dictionary \(document.data())")
           }
         }
         self.events = models
       }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return user!.document!.collection("events")
    }
    
    lazy var customCalendar: Calendar = {
      let customNSCalendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
      customNSCalendar.timeZone = TimeZone.current
      let calendar = customNSCalendar as Calendar
      return calendar
    }()
    
    override func loadView() {
      calendar = customCalendar
      dayView = DayView(calendar: calendar)
      view = dayView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Calendar"
        navigationItem.largeTitleDisplayMode = .never
        
        
        if !isOnlyView {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Event", style: .done, target: self, action: #selector(addEventCalendar))
        }
        
        //MARK: Instructions Setup
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
               
        dayView.autoScrollToFirstEvent = true
        query = baseQuery()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        coachMarksController.overlay.isUserInteractionEnabled = false
        observeQuery()
    }
       
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coachMarksController.stop(immediately: true)
        stopObserving()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UserDefaultManager.shared.isFirstCalendar && !isOnlyView {
            startInstructions()
            UserDefaultManager.shared.isFirstCalendar = false
        }

    }
    
    deinit {
      listener?.remove()
    }
    
    func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }
    
    @objc func addEventCalendar(){
        
        performSegue(withIdentifier: "addEventSegue", sender: nil)
        
    }
    
    // MARK: EventDataSource
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
      
        var events = [Event]()

        for model in self.events {
            
            if isOnlyView {
                if model.title == "FREE" {
                    let event = createEvent(model)
                    events.append(event)
                }
            }else{
                let event = createEvent(model)
                events.append(event)
            }
            
        }
        return events
        
    }
    
    private func createEvent(_ model: Eveent) -> Event{
        
        let event = Event()
        
        event.startDate = model.startDate
        event.endDate = model.endDate
        event.isAllDay = model.allDay
        event.userInfo = model
        
        var location = ""
        
        if model.title == "FREE" {
            event.color = .green
            location = "Click to send a request"
        }else if model.title == "BUSY" {
            event.color = .red
            if model.location.count > 1 {
                location = model.location
            }
        }
        
        var info = [model.title, location]
        info.append("\(event.startDate.format(with: "HH:mm")) - \(event.endDate.format(with: "HH:mm"))")
        event.text = info.reduce("", {$0 + $1 + "\n"})
        
        return event
    }

    private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
      var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
      return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
    }
    
    // MARK: DayViewDelegate
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? Event,
            let event = descriptor.userInfo as? Eveent else {
            return
        }
        
        print("Event has been selected: \(descriptor) \(String(describing: descriptor.userInfo))")
        
        if isOnlyView {
            
            if let userAuth = AuthenticationManager.shared.currentUser {
                
               userAuth.document!.collection("requests").whereField("eventID", isEqualTo: event.document!.documentID)
                .getDocuments { (querySnapshot, err) in
                    
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        
                        if querySnapshot!.documents.count > 0 {
                            self.popupShow(message: "You already have a request for this event")
                        }else{
                            self.performSegue(withIdentifier: "addRequestSegue", sender: event)
                        }
                    }
                }
            }
 
        }
        else{
            performSegue(withIdentifier: "addEventSegue", sender: event)
        }
    }
    

    override func dayView(dayView: DayView, willMoveTo date: Date) {
      print("DayView = \(dayView) will move to: \(date)")
    }
    
    override func dayView(dayView: DayView, didMoveTo date: Date) {
      print("DayView = \(dayView) did move to: \(date)")
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
        

        if segue.identifier == "addEventSegue" {
            
            let destinationVC = segue.destination as! AddEventViewController
            destinationVC.delegate = self
            destinationVC.dayView = dayView
            
             if let event = sender as? Eveent {
                destinationVC.event = event
            }

        }else if segue.identifier == "addRequestSegue" {
            
            let destinationVC = segue.destination as! AddRequestViewController
            destinationVC.tutor = self.user
            destinationVC.course = self.course
            
            if let event = sender as? Eveent {
                destinationVC.event = event
            }
            
        }
        
        
    }

}

extension CalendarView: AddEventControllerDelegate {
    
    func newEvent(event: Eveent?) {
        if let event = event {
            if let user = self.user {
                var ref: DocumentReference? = nil
                ref = user.document!.collection("events").addDocument(data: event.dictionary)  { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }
    }
    
    func editEvent(event: Eveent?) {
        if let event = event {
            
            event.document?.reference.updateData([
                "title": event.title,
                "location": event.location,
                "startDate": event.startDate,
                "endDate": event.endDate,
                "allDay": event.allDay
           ]){ err in
               if let err = err {
                   print("Error updating document: \(err)")
               } else {
                   print("Document successfully updated")
               }
           }
            
        }
     }
    
    func deleteEvent(event: Eveent?) {
        if let event = event {
            
            event.document?.reference.delete(){ err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
  
}

// MARK: Protocol Conformance | CoachMarksControllerDelegate
// Used for Snapshot testing (i. e. has nothing to do with the example)
extension CalendarView: CoachMarksControllerDelegate {
    
    
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

extension CalendarView: CoachMarksControllerDataSource {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        1
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
            coachViews.bodyView.hintLabel.text = self.calendarSectionText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
            coachViews.bodyView.nextControl?.addTarget(self, action: #selector(addEventCalendar), for: .touchUpInside)
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
      }
    
    
}
