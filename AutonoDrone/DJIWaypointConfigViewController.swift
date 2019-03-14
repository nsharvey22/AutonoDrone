//
//  DJIWaypointConfigViewController.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/8/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit

protocol DJIWaypointConfigViewControllerDelegate: NSObjectProtocol {
    func cancelBtnAction(in waypointConfigVC: DJIWaypointConfigViewController?)
    func finishBtnAction(in waypointConfigVC: DJIWaypointConfigViewController?)
}

class DJIWaypointConfigViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.altitudeTextField.delegate = self
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @IBOutlet weak var altitudeTextField: UITextField!
    @IBOutlet weak var autoFlightSpeedTextField: UITextField!
    @IBOutlet weak var maxFlightSpeedTextField: UITextField!
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var headingSegmentedControl: UISegmentedControl!
    weak var delegate: DJIWaypointConfigViewControllerDelegate?
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        delegate?.cancelBtnAction(in: self)
    }
    
    @IBAction func finishBtnAction(_ sender: Any) {
        delegate?.finishBtnAction(in: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func initUI() {
        altitudeTextField.keyboardType = UIKeyboardType.decimalPad
        altitudeTextField.text = "30" //Set the altitude to 100
        autoFlightSpeedTextField.keyboardType = UIKeyboardType.decimalPad
        autoFlightSpeedTextField.text = "8" //Set the autoFlightSpeed to 8
        maxFlightSpeedTextField.keyboardType = UIKeyboardType.decimalPad
        maxFlightSpeedTextField.text = "10" //Set the maxFlightSpeed to 10
        actionSegmentedControl.selectedSegmentIndex = 1 //Set the finishAction to DJIWaypointMissionFinishedGoHome
        headingSegmentedControl.selectedSegmentIndex = 0 //Set the headingMode to DJIWaypointMissionHeadingAuto
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
