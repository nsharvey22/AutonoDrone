//
//  WaypointOptionsViewController.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/14/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit

protocol WaypointOptionsViewControllerDelegate: NSObjectProtocol {
    func changeAltitude(in waypointOptionVC: WaypointOptionsViewController?)
    func changeHeading(in waypointOptionVC: WaypointOptionsViewController?)
    func changeGimbalPitch(in waypointOptionVC: WaypointOptionsViewController?)
    func setWaypointNum(in waypointOptionVC: WaypointOptionsViewController?)
}

class WaypointOptionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var waypointNum: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var gimbalPitchLabel: UILabel!
    
    @IBOutlet weak var altitudeSlider: UISlider!
    @IBOutlet weak var headingSlider: UISlider!
    @IBOutlet weak var gimbalSlider: UISlider!
    
    weak var delegate: WaypointOptionsViewControllerDelegate?
    
    func setWaypointNum() {
        delegate?.setWaypointNum(in: self)
    }
    
    @IBAction func changeAltitude(_ sender: Any) {
        delegate?.changeAltitude(in: self)
        altitudeSlider.value = roundf(altitudeSlider.value)
        altitudeLabel.text = "\(Int(altitudeSlider.value))"
    }
    
    @IBAction func changeHeading(_ sender: Any) {
        delegate?.changeHeading(in: self)
        headingSlider.value = roundf(headingSlider.value)
        headingLabel.text = "\(Int(headingSlider.value))"
    }
    
    @IBAction func changeGimbalPitch(_ sender: Any) {
        delegate?.changeGimbalPitch(in: self)
        gimbalSlider.value = roundf(gimbalSlider.value)
        gimbalPitchLabel.text = "\(Int(gimbalSlider.value))"
    }
    @IBAction func dismiss(_ sender: Any) {
        self.view.alpha = 0
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
