//
//  WaypointOptionsViewController.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/14/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit

class WaypointOptionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var gimbalPitchLabel: UILabel!
    
    @IBOutlet weak var altitudeSlider: UISlider!
    @IBOutlet weak var headingSlider: UISlider!
    @IBOutlet weak var gimbalSlider: UISlider!
    
    @IBAction func changeAltitude(_ sender: Any) {
        altitudeSlider.value = roundf(altitudeSlider.value)
        altitudeLabel.text = "\(Int(altitudeSlider.value))"
    }
    
    @IBAction func changeHeading(_ sender: Any) {
        headingSlider.value = roundf(headingSlider.value)
        headingLabel.text = "\(Int(headingSlider.value))"
    }
    
    @IBAction func changeGimbalPitch(_ sender: Any) {
        gimbalSlider.value = roundf(gimbalSlider.value)
        gimbalPitchLabel.text = "\(Int(gimbalSlider.value))"
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
