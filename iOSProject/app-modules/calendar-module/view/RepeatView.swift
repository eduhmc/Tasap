//
//  RepeatView.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 8/14/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

protocol RepeatViewDelegate: AnyObject {
    func repeatOption(re: String?, fo: String?)
}

class RepeatView: UIViewController {

    @IBOutlet weak var repeatPickerView: UIPickerView!
    @IBOutlet weak var forPickerView: UIPickerView!
    
    weak var delegate: RepeatViewDelegate?
    
    var repeatPickerData: [String] = [String]()
    var forPickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repeatPickerView.delegate = self
        repeatPickerView.dataSource = self
        repeatPickerView.tag = 1

        forPickerView.delegate = self
        forPickerView.dataSource = self
        forPickerView.tag = 2
        
        repeatPickerData = ["All Days", "All Weeks", "All Months"]
        forPickerData = ["1 Month", "2 Months", "3 Month"]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(doneButtonDidTap))

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelButtonDidTap))
        
    }
    
    @objc func doneButtonDidTap() {
        
        let re = repeatPickerData[repeatPickerView.selectedRow(inComponent: 0)]
        let fo = forPickerData[forPickerView.selectedRow(inComponent: 0)]
        delegate?.repeatOption(re: re, fo: fo)
        dismiss(animated: true, completion: nil)
    }

    @objc func cancelButtonDidTap() {
        delegate?.repeatOption(re: nil, fo: nil)
        dismiss(animated: true, completion: nil)
    }
 
}

extension RepeatView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? repeatPickerData.count : forPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerView.tag == 1 ? repeatPickerData[row] : forPickerData[row]
        
    }
    
    
    
}
