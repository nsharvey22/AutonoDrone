//
//  DJIGSButtonViewController.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/7/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit
import Floaty

enum DJIGSViewMode : Int {
    case _ViewMode
    case _EditMode
}

protocol DJIGSButtonViewControllerDelegate: NSObjectProtocol {
    func stopBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?)
    func clearBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?)
    func focusMapBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?)
    func startBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?)
    func addBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?)
    func configBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?)
    func switchTo(mode: DJIGSViewMode, inGSButtonVC GSBtnVC: DJIGSButtonViewController?)
}

class DJIGSButtonViewController: UIViewController, FloatyDelegate {
    let floaty = Floaty()
    let addWaypointItem = FloatyItem()
    let clearItem = FloatyItem()
    let configItem = FloatyItem()
    let startItem = FloatyItem()
    override func viewDidLoad() {
        super.viewDidLoad()
        setMode(DJIGSViewMode._ViewMode)
        // Do any additional setup after loading the view.
        
        Floaty.global.rtlMode = true
        floaty.autoCloseOnTap = false
        floaty.overlayColor = .clear
        floaty.buttonImage = UIImage(named: "waypoint_menu")
        floaty.buttonColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
        floaty.plusColor = .white
        floaty.tintColor = .white

        addWaypointItem.handler = { (item) in
            print("add wapoint mode")
            self.delegate?.addBtnAction(inGSButtonVC: self)
        }
        addWaypointItem.icon = UIImage(named: "waypoint")
        addWaypointItem.tintColor = .white
        addWaypointItem.buttonColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
        addWaypointItem.title = "Add Waypoints"
        floaty.addItem(item: addWaypointItem)
        
        clearItem.handler = { (item) in
            print("clearing waypoints")
            self.delegate?.clearBtnAction(inGSButtonVC: self)
        }
        clearItem.icon = UIImage(named: "clear_waypoint")
        clearItem.tintColor = .white
        clearItem.buttonColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
        clearItem.title = "Clear Waypoints"
        clearItem.isHidden = true
        floaty.addItem(item: clearItem)
        
        configItem.handler = { (item) in
            print("configuring waypoints")
            self.delegate?.configBtnAction(inGSButtonVC: self)
        }
        configItem.icon = UIImage(named: "config_waypoint")
        configItem.tintColor = .white
        configItem.buttonColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
        configItem.title = "Conifigure Waypoints"
        configItem.isHidden = true
        floaty.addItem(item: configItem)
        
        startItem.handler = { (item) in
            print("starting mission")
            self.delegate?.startBtnAction(inGSButtonVC: self)
            self.floaty.close()
        }
        startItem.icon = UIImage(named: "waypoint")
        startItem.tintColor = .white
        startItem.buttonColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
        startItem.title = "Start Mission"
        startItem.isHidden = true
        floaty.addItem(item: startItem)

        self.view.addSubview(floaty)
    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var focusMapBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var configBtn: UIButton!
    var mode: DJIGSViewMode?
    weak var delegate: DJIGSButtonViewControllerDelegate?
    
    func setMode(_ mode: DJIGSViewMode) {
        //_mode = mode
        
//        editBtn.isHidden = (mode == DJIGSViewMode._EditMode)
//        focusMapBtn.isHidden = (mode == DJIGSViewMode._EditMode)
//        backBtn.isHidden = (mode == DJIGSViewMode._ViewMode)
//        clearBtn.isHidden = (mode == DJIGSViewMode._ViewMode)
//        startBtn.isHidden = (mode == DJIGSViewMode._ViewMode)
//        stopBtn.isHidden = (mode == DJIGSViewMode._ViewMode)
//        addBtn.isHidden = (mode == DJIGSViewMode._ViewMode)
//        configBtn.isHidden = (mode == DJIGSViewMode._ViewMode)
    }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
        setMode(DJIGSViewMode._ViewMode)
    }
    
    @IBAction func stopBtnAction(_ sender: Any) {
        delegate?.stopBtnAction(inGSButtonVC: self)
    }
    
    @IBAction func clearBtnAction(_ sender: Any) {
        delegate?.clearBtnAction(inGSButtonVC: self)
    }
    
    @IBAction func focusMapBtnAction(_ sender: Any) {
        delegate?.focusMapBtnAction(inGSButtonVC: self)
    }
    
    @IBAction func editBtnAction(_ sender: Any) {
        setMode(DJIGSViewMode._EditMode)
    }
    
    @IBAction func startBtnAction(_ sender: Any) {
        delegate?.startBtnAction(inGSButtonVC: self)
    }
    
    @IBAction func addBtnAction(_ sender: Any) {
        delegate?.addBtnAction(inGSButtonVC: self)
    }
    
    @IBAction func configBtnAction(_ sender: Any) {
        delegate?.configBtnAction(inGSButtonVC: self)
    }
        
    // MARK: - Floaty Delegate Methods
    func floatyWillOpen(_ floaty: Floaty) {
        print("Floaty Will Open")
    }
    
    func floatyDidOpen(_ floaty: Floaty) {
        print("Floaty Did Open")
    }
    
    func floatyWillClose(_ floaty: Floaty) {
        print("Floaty Will Close")
    }
    
    func floatyDidClose(_ floaty: Floaty) {
        print("Floaty Did Close")
    }
}
