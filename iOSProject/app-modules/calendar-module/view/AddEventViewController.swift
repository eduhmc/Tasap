//
//  AddEventViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/13/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import CalendarKit
import Instructions

protocol AddEventControllerDelegate: AnyObject {
    func newEvent(event: Eveent?, re: String?, fo: String?)
    func editEvent(event: Eveent?)
    func deleteEvent(event: Eveent?)
}

class AddEventViewController: UIViewController {

    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var deleteEventButton: UIButton!
    
    @IBOutlet weak var repeatSwitch: UISwitch!
    @IBOutlet weak var repeatView: UIView!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var forLabel: UILabel!
    
    
    // MARK: - Public properties
    var coachMarksController = CoachMarksController()
    
    let addEventSectionText = "To finish, you have to add an event on the dates you consider convenient."
    let nextButtonText = "Ok!"
    
    weak var snapshotDelegate: CoachMarksControllerDelegate?
    
    weak var delegate: AddEventControllerDelegate?
    weak var dayView: DayView?
    var event: Eveent?
    
    var repit: String?
    var ford: String?

    var startDateClick = false
    var endDateClick = false
    
    var startDate: Date? {
        didSet {
            startDateLabel.text = startDate?.format(with: "dd MMM YYYY HH:mm aa")
        }
    }
    var endDate: Date? {
        didSet {
            endDateLabel.text = endDate?.format(with: "dd MMM YYYY HH:mm aa")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Instructions Setup
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        //MARK: Init Setup
        self.setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UserDefaultManager.shared.isFirstAddEvent {
            startInstructions()
            UserDefaultManager.shared.isFirstAddEvent = false
        }
 
    }
    
    func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }
    
    
    func setup() {
        
        
        navigationItem.largeTitleDisplayMode = .always
        
        if let event = event {
            title = "Edit Event"
            if event.title == "FREE" {
                stateSwitch.isOn = true
                 stateLabel.text = "Free"
            }else if event.title == "BUSY" {
                stateSwitch.isOn = false
                stateLabel.text = "Busy"
            }
            
            startDate = event.startDate
            endDate = event.endDate
            eventButton.setTitle("Edit Event", for: .normal)
            deleteEventButton.isHidden = false
            
        }else{
            
            title = "Add Event"
            startDate = dayView!.state!.selectedDate
            endDate = dayView!.state!.selectedDate

            eventButton.setTitle("Add Event", for: .normal)
            deleteEventButton.isHidden = true
        }
    }
    
    func presentDatePicker(date: Date) {
        let picker = DatePickerController()
        
        picker.date = date //dayView!.state!.selectedDate
        picker.datePicker.minuteInterval = 30
        picker.delegate = self
        let navC = UINavigationController(rootViewController: picker)
        navigationController?.present(navC, animated: true, completion: nil)
    }
    
    @IBAction func stateSwitchTapped(_ sender: Any) {
        if stateSwitch.isOn {
            stateLabel.text = "Free"
        }else{
            stateLabel.text = "Busy"
        }
    }
    
    @IBAction func repeatSwitchTapped(_ sender: Any) {
        if repeatSwitch.isOn {
            repeatView.isHidden = false
            repit = "All Days"
            ford = "1 Month"
            repeatLabel.text = repit
            forLabel.text = ford
        }else{
            repeatView.isHidden = true
            repit = nil
            ford = nil
        }
    }
    
    
    @IBAction func startDateButtonTapped(_ sender: Any) {
        startDateClick = true
        
        presentDatePicker(date: startDate!)
    }
    
    @IBAction func endDateButtonTapped(_ sender: Any) {
        endDateClick = true
        presentDatePicker(date: endDate!)
    }
    
    @IBAction func repeatButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "Calendar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RepeatView") as! RepeatView
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        navigationController?.present(navC, animated: true, completion: nil)
        
        
    }
    
    @IBAction func addEventTapped(_ sender: Any) {
        
        guard let title = stateSwitch.isOn ? "FREE" : "BUSY",
            let startDate = startDate,
            let endDate = endDate  else {
            return
        }

        let allDay = false
        
        if var event = event {
            event.title = title
            event.location = ""
            event.startDate = startDate
            event.endDate = endDate
            event.allDay = allDay
            delegate?.editEvent(event: event)
        }else{
            event = Eveent(title: title, location: "", startDate: startDate, endDate: endDate,allDay: allDay)
            delegate?.newEvent(event: event, re: repit, fo: ford)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteEventTapped(_ sender: Any) {
        
        delegate?.deleteEvent(event: event)
        navigationController?.popViewController(animated: true)
    }

}

extension AddEventViewController: RepeatViewDelegate {
    
    func repeatOption(re: String?, fo: String?) {
        
        self.repit = re
        self.ford = fo
        
        if let repit = re, let ford = fo {
            repeatLabel.text = repit
            forLabel.text = ford
        }
        
    }
}

extension AddEventViewController: DatePickerControllerDelegate {
    
    func datePicker(controller: DatePickerController, didSelect date: Date?) {
        if let date = date {
            if startDateClick {
                startDate = date
                startDateClick = false
            }
            if endDateClick {
                endDate = date
                endDateClick = false
            }
        }
    }
    
}

// MARK: Protocol Conformance | CoachMarksControllerDelegate
// Used for Snapshot testing (i. e. has nothing to do with the example)
extension AddEventViewController: CoachMarksControllerDelegate {
    
    
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

extension AddEventViewController: CoachMarksControllerDataSource {
    
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
            coachViews.bodyView.hintLabel.text = self.addEventSectionText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
      }
    
    
}
