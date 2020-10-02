//
//  RequestsViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/6/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import PopupDialog
import FirebaseFirestore

class RequestView: UIViewController, RequestPresenterToViewProtocol {
    
    @IBOutlet weak var requestSegmented: UISegmentedControl!
    @IBOutlet weak var requestTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var requestSegmenteHeight: NSLayoutConstraint!
    
    var presenter: RequestViewToPresenterProtocol?
    
    var user: User?
    
    var isloadView = false
    
    private var dates: [Date] = [] {
        didSet{
            emptyLabel.isHidden = dates.count > 0
            requestTableView.reloadData()
        }
    }

    var isMyRequest = true
    
    func showRequests(dates: [Date], title: String) {
        setup(title: title)
        self.dates = dates
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userAuth = AuthenticationManager.shared.currentUser {
            
            if !userAuth.isTutor {
                requestSegmenteHeight.constant = 0
                requestSegmented.isHidden = true
                updateViewConstraints()
            }else{
                requestSegmenteHeight.constant = 31
                updateViewConstraints()
                requestSegmented.isHidden = false
            }
            
        }
        
        let type =  isMyRequest ? "USER" : "TUTOR"
        presenter?.loadRequests(type: type, fromView: self)
        isloadView = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        if !isloadView{
            let type =  isMyRequest ? "USER" : "TUTOR"
            presenter?.loadRequests(type: type, fromView: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.stopObserving()
    }
    
    func setup(title: String){
        
        requestTableView.delegate = self
        requestTableView.dataSource = self
        
        requestSegmented.removeAllSegments()
        requestSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        self.title = title
        emptyLabel.text = "No pending \(title.lowercased())"
        requestSegmented.insertSegment(withTitle: "My \(title)", at: 0, animated: false)
        requestSegmented.insertSegment(withTitle: "User \(title)", at: 1, animated: false)
        
        requestSegmented.selectedSegmentIndex = isMyRequest ? 0 : 1
 
    }
    
    deinit {
        presenter?.stopObserving()
    }
    
    @IBAction func requestSegmentedTapped(_ sender: Any) {
        isMyRequest = requestSegmented.selectedSegmentIndex == 0 ? true : false
        let type =  isMyRequest ? "USER" : "TUTOR"
        presenter?.loadRequests(type: type, fromView: self)
    }
}

extension RequestView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        isloadView = false
        let date = dates[indexPath.row]
        presenter?.showRequestDetail(date: date, fromView: self)
    }
}

extension RequestView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestCell
        
        let date = dates[indexPath.row]
        cell.setup(date: date)
        return cell
        
    }
    
}
