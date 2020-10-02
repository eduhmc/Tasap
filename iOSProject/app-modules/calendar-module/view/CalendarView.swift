//
//  CalendarViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/11/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import CalendarKit
import DateToolsSwift
import FirebaseFirestore
import PopupDialog
import Instructions

class CalendarView : DayViewController, CalendarPresenterToViewProtocol {
    
    // MARK: - Public properties
    var coachMarksController = CoachMarksController()
    
    var presenter: CalendarViewToPresenterProtocol?
    
    let calendarSectionText = "You are in the calendar section, where you can add your availability."
    let nextButtonText = "Ok!"
    
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    var model: CalendarModel?

    var events = [Eveent]() {
        didSet{
            reloadData()
        }
    }
    
    var colors = [UIColor.blue,
                  UIColor.yellow,
                  UIColor.green,
                  UIColor.red]
    
    func showEvents(model: CalendarModel) {
        self.model = model
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
        
        if let model = model {
            return model.user!.document!.collection("events")
        }else{
            return Firestore.firestore().collection("demo")
        }
        
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
        
        presenter?.loadEvents()
        title = "Calendar"
        navigationItem.largeTitleDisplayMode = .never
        
        if let model = model {
            
            if !model.isOnlyView {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Event", style: .done, target: self, action: #selector(addEventCalendar))
            }
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
        
        if let model = model {
            if UserDefaultManager.shared.isFirstCalendar && !model.isOnlyView {
                startInstructions()
                UserDefaultManager.shared.isFirstCalendar = false
            }
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
        
        for event in self.events {
            
            if let model = model {
                if model.isOnlyView {
                    if event.title != "BUSY" {
                        let event = createEvent(event)
                        events.append(event)
                    }
                }else{
                    let event = createEvent(event)
                    events.append(event)
                }
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
        }else if model.title == "BUSY" || model.title == "MEETING" {
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
        
        if let model = model {
            if model.isOnlyView {
                
                if event.endDate > Date() {
                    
                    if let userAuth = AuthenticationManager.shared.currentUser {
                        
                        if let user = model.user, user.document?.documentID != userAuth.document?.documentID {
                            
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
                    
                }else {
                    self.popupShow(message: "The event is not available")
                }
                
            }
            else{
                performSegue(withIdentifier: "addEventSegue", sender: event)
            }
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
            destinationVC.tutor = model?.user
            destinationVC.course = model?.course
            destinationVC.model = model
            
            if let event = sender as? Eveent {
                destinationVC.event = event
            }
            
        }
        
        
    }
    
}

extension CalendarView: AddEventControllerDelegate {
    
    func newEvent(event: Eveent?, re: String?, fo: String?) {
        if let event = event {
            if let user = model?.user {
                
                if let repit = re, let ford = fo {
                    
                    switch repit {
                    case "All Days":
                        
                        switch ford {
                        case "1 Month":
                            
                            var copyEvent = event
                             
                            for _ in 1...30 {
                                
                                addEventFirestore(user: user, event: copyEvent)
                                copyEvent.startDate = copyEvent.startDate.addingTimeInterval(86400)
                                copyEvent.endDate = copyEvent.endDate.addingTimeInterval(86400)
                            }
                            
                            break
                        case "2 Months":
                            
                            var copyEvent = event
                             
                            for _ in 1...60 {
                                
                                addEventFirestore(user: user, event: copyEvent)
                                copyEvent.startDate = copyEvent.startDate.addingTimeInterval(86400)
                                copyEvent.endDate = copyEvent.endDate.addingTimeInterval(86400)
                            }
                            
                            break
                        case "3 Months":
                            
                            var copyEvent = event
                             
                            for _ in 1...90 {
                                
                                addEventFirestore(user: user, event: copyEvent)
                                copyEvent.startDate = copyEvent.startDate.addingTimeInterval(86400)
                                copyEvent.endDate = copyEvent.endDate.addingTimeInterval(86400)
                            }
                            
                            break
                        default:
                            break
                        }
                        
                        break
                    case "All Weeks":
                        
                        switch ford {
                        case "1 Month":
                            
                            var copyEvent = event
                             
                            for _ in 1...4 {
                                
                                addEventFirestore(user: user, event: copyEvent)
                                copyEvent.startDate = copyEvent.startDate.addingTimeInterval(604800)
                                copyEvent.endDate = copyEvent.endDate.addingTimeInterval(604800)
                            }
                            
                            break
                        case "2 Months":
                            
                            var copyEvent = event
                             
                            for _ in 1...8 {
                                
                                addEventFirestore(user: user, event: copyEvent)
                                copyEvent.startDate = copyEvent.startDate.addingTimeInterval(604800)
                                copyEvent.endDate = copyEvent.endDate.addingTimeInterval(604800)
                            }
                            
                            break
                        case "3 Months":
                            
                            var copyEvent = event
                             
                            for _ in 1...12 {
                                
                                addEventFirestore(user: user, event: copyEvent)
                                copyEvent.startDate = copyEvent.startDate.addingTimeInterval(604800)
                                copyEvent.endDate = copyEvent.endDate.addingTimeInterval(604800)
                            }
                            
                            break
                        default:
                            break
                        }
                        
                        break
                    case "All Months":
                        
                        switch ford {
                        case "1 Month":
                            
                            addEventFirestore(user: user, event: event)
                            
                            var copyEvent = event
                            
                            var dateComponent = DateComponents()
                            dateComponent.month = 1
                            
                            copyEvent.startDate = Calendar.current.date(byAdding: dateComponent, to: copyEvent.startDate)!
                            
                            copyEvent.endDate = Calendar.current.date(byAdding: dateComponent, to: copyEvent.endDate)!
                            
                            addEventFirestore(user: user, event: copyEvent)
                            
                            break
                        case "2 Months":
                            
                            addEventFirestore(user: user, event: event)
                            
                            var copyEvent = event
                            
                            for _ in 1...2 {
                                
                                var dateComponent = DateComponents()
                                dateComponent.month = 1
                                
                                copyEvent.startDate = Calendar.current.date(byAdding: dateComponent, to: copyEvent.startDate)!
                                
                                copyEvent.endDate = Calendar.current.date(byAdding: dateComponent, to: copyEvent.endDate)!
                                
                                addEventFirestore(user: user, event: copyEvent)
                                
                            }
                            
                            break
                        case "3 Months":
                            
                            addEventFirestore(user: user, event: event)
                            
                            var copyEvent = event
                            
                            for _ in 1...3 {
                                
                                var dateComponent = DateComponents()
                                dateComponent.month = 1
                                
                                copyEvent.startDate = Calendar.current.date(byAdding: dateComponent, to: copyEvent.startDate)!
                                
                                copyEvent.endDate = Calendar.current.date(byAdding: dateComponent, to: copyEvent.endDate)!
                                
                                addEventFirestore(user: user, event: copyEvent)
                                
                            }
                            
                            break
                        default:
                            break
                        }
                        
                        break
                    default:
                        break
                    }
                    
                    
                }else{
                    addEventFirestore(user: user, event: event)
                }
                
            }
        }
    }
    
    func addEventFirestore(user: User, event: Eveent){
        
        var ref: DocumentReference? = nil
        ref = user.document!.collection("events").addDocument(data: event.dictionary)  { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
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
