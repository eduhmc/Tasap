//
//  RequestDayViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 7/24/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit
import PopupDialog
import FirebaseFirestore

class RequestDetailView: UIViewController, RequestDetailPresenterToViewProtocol {
   
    @IBOutlet weak var requestSegmented: UISegmentedControl!
    @IBOutlet weak var requestTableView: UITableView!
    @IBOutlet weak var requestSegmenteHeight: NSLayoutConstraint!
    
    var presenter: RequestDetailViewToPresenterProtocol?
    
    var user: User?
    var requests: [Request] = []
    var isOnTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        setup()
        presenter?.loadDetail(isOnTime: isOnTime)
    }
    
    func setup(){
        requestTableView.delegate = self
        requestTableView.dataSource = self
    }
    
    func showDetail(requests: [Request], hiddenSegmented: Bool) {
        
        if hiddenSegmented {
            requestSegmenteHeight.constant = 0
            updateViewConstraints()
            requestSegmented.isHidden = true
        }else{
            requestSegmenteHeight.constant = 31
            updateViewConstraints()
            requestSegmented.isHidden = false
        }
        
        self.requests = requests
        self.requestTableView.reloadData()
    }
    
    @IBAction func requestSegmentedTapped(_ sender: Any) {
        isOnTime  = requestSegmented.selectedSegmentIndex == 0 ? true : false
        presenter?.loadDetail(isOnTime: isOnTime)
        
    }

}

extension RequestDetailView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let request = requests[indexPath.row]
        presenter?.actionRequest(request: request, view: self)
 
    }
}

extension RequestDetailView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 176
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestDetailCell", for: indexPath) as! RequestDetailCell
        let request = requests[indexPath.row]
        cell.setup(request: request)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let request = self.requests[indexPath.row]
        
        if request.state == "ACCEPTED" &&  request.type == .userRequest {
            
            let blockAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, complete in

                self.presenter?.cancelRequest(request: request, view: self)
                complete(true)
            }

            return UISwipeActionsConfiguration(actions: [blockAction])
            
        }
        
        return UISwipeActionsConfiguration(actions: [])
        
    }
    
    
    
    
}

