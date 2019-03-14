//
//  DefaultLayoutViewController.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/6/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit
import DJISDK
import DJIUXSDK
import DJIWidget
import CoreLocation
import GLKit

class DefaultLayoutViewController: DUXDefaultLayoutViewController, DJISDKManagerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, DJIFlightControllerDelegate, DJIGSButtonViewControllerDelegate, DJIWaypointConfigViewControllerDelegate {
    
    // MARK:- DJIWaypointConfigViewControllerDelegate
    
    func cancelBtnAction(in waypointConfigVC: DJIWaypointConfigViewController?) {
        // TODO implement weak self reference incase self is ever nil
        UIView.animate(withDuration: 0.25, animations: {
            self.waypointConfigVC?.view.alpha = 0
            self.visualEffectView.alpha = 0
        })
    }
    
    func finishBtnAction(in waypointConfigVC: DJIWaypointConfigViewController?) {
        // TODO implement weak self reference incase self is ever nil
        UIView.animate(withDuration: 0.25, animations: {
            self.waypointConfigVC?.view.alpha = 0
            self.visualEffectView.alpha = 0
        })
        
        let wayPoints = mapController.wayPoints
        
        if wayPoints == nil || wayPoints().count < 2 {
            //DJIWaypointMissionMinimumWaypointCount is 2.
            print("No or not enough waypoints for mission")
        }
        
        if (waypointMission != nil) {
            waypointMission?.removeAllWaypoints()
        } else {
            waypointMission = DJIMutableWaypointMission()
        }
        
        for i in 0..<wayPoints().count {
            let location = wayPoints()[i] as? CLLocation
            if CLLocationCoordinate2DIsValid((location?.coordinate)!) {
                var waypoint: DJIWaypoint? = nil
                if let coordinate = location?.coordinate {
                    waypoint = DJIWaypoint(coordinate: coordinate)
                }
                if let text = self.waypointConfigVC?.altitudeTextField.text {
                    waypoint?.altitude = Float(text)!
                }
                waypointMission?.add(waypoint!)
            }
        }
        
        if let text = self.waypointConfigVC?.maxFlightSpeedTextField.text {
            waypointMission?.maxFlightSpeed = Float(text)!
        }
        if let text = self.waypointConfigVC?.autoFlightSpeedTextField.text {
            waypointMission?.autoFlightSpeed = Float(text)!
        }
        if let selected = self.waypointConfigVC?.headingSegmentedControl.selectedSegmentIndex {
            waypointMission?.headingMode = DJIWaypointMissionHeadingMode(rawValue: UInt(selected))!
        }
        if let selected = self.waypointConfigVC?.actionSegmentedControl.selectedSegmentIndex {
            waypointMission?.finishedAction = DJIWaypointMissionFinishedAction(rawValue: UInt8(selected))!
            
        }
        
        missionOperator()?.load(waypointMission!)
        
        
        missionOperator()?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { error in
            if error != nil {
                if let description = error?.localizedDescription {
                    self.showAlertView(withTitle: "Mission Execution Failed", withMessage: "\(description)")
                    self.button?.isHidden = true
                    self.view.layer.sublayers?.forEach({$0.removeAllAnimations()})
                }
            } else {
                self.showAlertView(withTitle: "Mission Execution Finished", withMessage: nil)
                self.button?.isHidden = true
                self.view.layer.sublayers?.forEach({$0.removeAllAnimations()})
            }
        })

        
        missionOperator()?.uploadMission(completion: { error in
            if error != nil {
                var uploadError: String? = nil
                if let description = error?.localizedDescription {
                    uploadError = "Upload Mission failed:\(description)"
                }
                print("", uploadError)
            } else {
                print("", "Upload Mission Finished")
                self.gsButtonVC?.startItem.isHidden = false
                self.gsButtonVC?.floaty.close()
                self.gsButtonVC?.floaty.open()
            }
        })
        
        
        print("count: ", DJIWaypointUploadProgress().totalWaypointCount)
        
        missionOperator()?.addListener(toUploadEvent: self, with: DispatchQueue.main, andBlock: { (error) in
            print("upload progress: ", self.missionOperator()?.latestUploadProgress)
            if error != nil {
                
                print("Upload Mission failed: ")
                
                
            } else {
                print("", "Uploading...")
            }
        })
    }
    
    // MARK:- DJIGSButtonViewControllerDelegate
    
    func stopBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?) {
        
        missionOperator()?.stopMission(completion: { error in
            if error != nil {
                var failedMessage: String? = nil
                if let description = error?.localizedDescription {
                    failedMessage = "Stop Mission Failed: \(description)"
                }
                print("", failedMessage)
                
            } else {
                print("", "Stop Mission Finished")
                self.button?.isHidden = true
                self.view.layer.removeAllAnimations()
            }
            
        })
    }
    
    func clearBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?) {
        mapController.cleanAllPoints(with: mapView)
        GSBtnVC?.clearItem.isHidden = true
        isEditingPoints = false
        GSBtnVC?.addWaypointItem.title = "Add Waypoints"
        GSBtnVC?.configItem.isHidden = true
        GSBtnVC?.startItem.isHidden = true
        if let overlays = mapView?.overlays {
            mapView?.removeOverlays(overlays)
        }
    }
     
    func focusMapBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?) {
        focusMap()
    }
    
    func startBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?) {
        
        missionOperator()?.startMission(completion: { error in
            if error != nil {
                print("Start Mission Failed", error?.localizedDescription)
            } else {
                print("", "Mission Started")
                self.button?.isHidden = false
                self.addPulse(button: self.button)
                GSBtnVC?.startItem.isHidden = true
            }
        })
    }
    @objc func buttonAction(sender: UIButton!) {
        print("stop button tapped")
        missionOperator()?.stopMission(completion: { error in
            if error != nil {
                var failedMessage: String? = nil
                if let description = error?.localizedDescription {
                    failedMessage = "Stop Mission Failed: \(description)"
                }
                print("", failedMessage)
                self.button?.isHidden = true
                self.view.layer.sublayers?.forEach({$0.removeAllAnimations()})
            } else {
                print("", "Stop Mission Finished")
                self.button?.isHidden = true
                self.view.layer.sublayers?.forEach({$0.removeAllAnimations()})
            }
            
        })
    }
    
    func addBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?) {
        if isEditingPoints {
            isEditingPoints = false
            GSBtnVC?.addWaypointItem.title = "Add Waypoints"

            if mapController.wayPoints().count > 0 {
                GSBtnVC?.configItem.isHidden = false
                GSBtnVC?.floaty.close()
                GSBtnVC?.floaty.open()
            }
        } else {
            isEditingPoints = true
            GSBtnVC?.addWaypointItem.title = "Finished"

        }
    }
    
    func configBtnAction(inGSButtonVC GSBtnVC: DJIGSButtonViewController?) {
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.alpha = 1
        }

        UIView.animate(withDuration: 0.25, animations: {
            self.waypointConfigVC?.view.alpha = 1.0
        })
        
        
    }
    
    func switchTo(mode: DJIGSViewMode, inGSButtonVC GSBtnVC: DJIGSButtonViewController?) {

    }
    
    
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var videoPreview: UIView!
   // @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewWidth: NSLayoutConstraint!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapViewTrailing: NSLayoutConstraint!
    
    private var gsButtonVC: DJIGSButtonViewController?
    private var waypointConfigVC: DJIWaypointConfigViewController?
    private var waypointOptVC: WaypointOptionsViewController?
    var waypointMission: DJIMutableWaypointMission?
    
    var mapView: MKMapView?
    let mapController:DJIMapController = DJIMapController()
    var button: UIButton?
    var focusBtn: UIButton?
    var mapTypeBtn: UIButton?
    var isEditingPoints: Bool = false
    var tapGesture: UITapGestureRecognizer?
    
    let mymapviewController = MapViewController()
    let myredcontroller = UIViewController()
    let fpvViewController = FPVViewController()
    
    var mapViewCenter: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var locationManager = CLLocationManager()
    var mapExtended:Bool = false
    var userLocation: CLLocationCoordinate2D!
    var droneLocation: CLLocationCoordinate2D?
    var savedFrame: CGRect?
    
    var mapTapRecognizer: UIGestureRecognizer?
    var videoTapRecognizer: UIGestureRecognizer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    @IBAction func close () {
        self.dismiss(animated: true) {
            
        }
    }
    var isContentViewSwitched = false
    var oldContentViewController: DUXFPVViewController?
    var oldPreviewViewController: MapViewController?
    // We are going to add focus adjustment to the default view.
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.mapView = (previewViewController?.view.subviews[0])! as! MKMapView
        let newContentVC = contentViewController as! DUXFPVViewController
        newContentVC.canDisplayGridOverlay = true
        newContentVC.currentGridOverlayType = DUXFPVViewGridOverlayType.grid
        newContentVC.fpvView?.alwaysShowDJICameraVideoFeed = true
        newContentVC.fpvView?.showCameraDisplayName = false
        contentViewController = newContentVC
        previewViewController = mymapviewController
        self.mapView = mymapviewController.mapWidgetController?.mapWidget.mapView
        mapView?.delegate = self
        
        
        mapTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        mapTapRecognizer?.delegate = self as! UIGestureRecognizerDelegate
        mapTapRecognizer?.cancelsTouchesInView = false
        previewViewController?.view.addGestureRecognizer(mapTapRecognizer!)

        videoTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        videoTapRecognizer?.delegate = self as! UIGestureRecognizerDelegate
        contentViewController?.view.addGestureRecognizer(videoTapRecognizer!)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(addWaypoints(_:)))
        

        mapView?.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            print("Please turn on location services")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.registerApp()
    }
    
    func initUI() {
        
        self.gsButtonVC = DJIGSButtonViewController(nibName: "DJIGSButtonViewController", bundle: Bundle.main)
        self.gsButtonVC?.view.frame = CGRect(x: 44, y: 44, width: (self.gsButtonVC?.view.frame.size.width)!, height: (self.gsButtonVC?.view.frame.size.height)!)
        self.gsButtonVC?.delegate = self
        // self.gsButtonVC?.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview((self.gsButtonVC?.view)!)
//        self.gsButtonVC?.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
//        self.gsButtonVC?.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 100).isActive = true
        gsButtonVC?.view.isHidden = true
        
        view.addSubview(visualEffectView)
        visualEffectView.frame = CGRect(x:0, y: 0, width:self.view.frame.width, height:self.view.frame.height)
        visualEffectView.alpha = 0
        
        
        waypointConfigVC = DJIWaypointConfigViewController(nibName: "DJIWaypointConfigViewController", bundle: Bundle.main)
        waypointConfigVC?.view.alpha = 0
        
        waypointConfigVC?.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        let configVCOriginX: CGFloat = (view.frame.width - (waypointConfigVC?.view.frame.width)!) / 2
        let configVCOriginY: CGFloat = 0
        
        waypointConfigVC?.view.frame = CGRect(x: configVCOriginX, y: configVCOriginY, width: (waypointConfigVC?.view.frame.width)!, height: (waypointConfigVC?.view.frame.height)!)
        waypointConfigVC?.view.center = view.center
        if UIDevice.current.userInterfaceIdiom == .pad {
            waypointConfigVC?.view.center = view.center
        }
        
        waypointConfigVC?.delegate = self
        view.addSubview((waypointConfigVC?.view)!)
        
        self.hideKeyboardWhenTappedAround()
        
        
        waypointOptVC = WaypointOptionsViewController(nibName: "WaypointOptionsViewController", bundle: Bundle.main)
       // waypointOptVC?.view.alpha = 0
        
        waypointOptVC?.view.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        let optionsVCOriginX: CGFloat = (view.frame.width - (waypointOptVC?.view.frame.width)!) / 2
        let optionsVCOriginY: CGFloat = 0
        
        waypointOptVC?.view.frame = CGRect(x: configVCOriginX, y: configVCOriginY, width: (waypointOptVC?.view.frame.width)!, height: (waypointOptVC?.view.frame.height)!)
        waypointOptVC?.view.center = view.center
        if UIDevice.current.userInterfaceIdiom == .pad {
            waypointOptVC?.view.center = view.center
        }
        
      //  waypointOptVC?.delegate = self
        view.addSubview((waypointOptVC?.view)!)
        
        button = UIButton(frame: CGRect(x: 120, y: 150, width: 50, height: 50))
        button?.backgroundColor = .red
        button?.layer.cornerRadius = 25
        button?.setTitle("Stop", for: UIControl.State())
        button?.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        //addPulse(button: button)
        view.addSubview(button!)
        button?.isHidden = true
        
        focusBtn = UIButton(frame: CGRect(x: 700, y: 70, width: 50, height: 50))
        focusBtn?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
        focusBtn?.layer.cornerRadius = 10
        focusBtn?.setImage(UIImage(named: "location"), for: UIControl.State())
        focusBtn?.tintColor = .white
        focusBtn?.addTarget(self, action: #selector(focusMap), for: .touchUpInside)
        view.addSubview(focusBtn!)
        focusBtn?.isHidden = true
        
        mapTypeBtn = UIButton(frame: CGRect(x: 700, y: 130, width: 50, height: 50))
        mapTypeBtn?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
        mapTypeBtn?.layer.cornerRadius = 10
        mapTypeBtn?.setImage(UIImage(named: "earth"), for: UIControl.State())
        mapTypeBtn?.tintColor = .white
        mapTypeBtn?.addTarget(self, action: #selector(mapType), for: .touchUpInside)
        view.addSubview(mapTypeBtn!)
        mapTypeBtn?.isHidden = true
        
//        let trackLayer = CAShapeLayer()
//        let center = view.center
//        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
//        trackLayer.path = circularPath.cgPath
//        trackLayer.strokeColor = UIColor.lightGray.cgColor
//        trackLayer.lineWidth = 10
//        trackLayer.lineCap = CAShapeLayerLineCap.round
//        trackLayer.strokeEnd = 0
//        view.layer.addSublayer(trackLayer)
//
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = circularPath.cgPath
//        shapeLayer.strokeColor = UIColor.red.cgColor
//        shapeLayer.lineWidth = 10
//        shapeLayer.lineCap = CAShapeLayerLineCap.round
//        shapeLayer.strokeEnd = 0
//        view.layer.addSublayer(shapeLayer)
//
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        basicAnimation.toValue = 1
//        basicAnimation.duration = 2
//        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
//        basicAnimation.isRemovedOnCompletion = false
//        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    var map = 0
    @objc func mapType() {
        var standard = mapView?.mapType
        var satellite = mapView?.mapType
        var hybrid = mapView?.mapType
        standard = .standard
        satellite = .satellite
        hybrid = .hybrid
        
        let mapArray:[MKMapType] = [standard!, satellite!, hybrid!]
        mapView?.mapType = mapArray[map]
        if map < 2 {
            map += 1
        } else {
            map = 0
        }
    }
    
    func addPulse(button: UIButton?){
        if button != nil {
            let pulse = Pulsing(numberOfPulses: Float.infinity, radius: 50, position: (button?.center)!)
            pulse.repeatCount = Float.infinity
            pulse.animationDuration = 2
            pulse.backgroundColor = UIColor.red.cgColor
            self.view.layer.insertSublayer(pulse, at: 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let pulse2 = Pulsing(numberOfPulses: Float.infinity, radius: 50, position: (button?.center)!)
                pulse2.repeatCount = Float.infinity
                pulse2.animationDuration = 2
                pulse2.backgroundColor = UIColor.red.cgColor
                self.view.layer.insertSublayer(pulse2, at: 2)
            }
            
        }
        
    }

    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        print("ButtonTapped")
        contentViewController?.view.removeGestureRecognizer(videoTapRecognizer!)
        previewViewController?.view.removeGestureRecognizer(mapTapRecognizer!)
        if (isContentViewSwitched) {
            isContentViewSwitched = false
            
            
//            UIView.animate(withDuration: 0.2, animations: {
//                self.fpvViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            }) { (_) in
//
//            }
            self.previewViewController = self.myredcontroller
            self.contentViewController = self.oldContentViewController
            
            self.previewViewController = self.mymapviewController
            
            self.previewViewController?.view.addGestureRecognizer(self.videoTapRecognizer!)
            
            self.focusBtn?.isHidden = true
            self.mapTypeBtn?.isHidden = true
            self.gsButtonVC?.view.isHidden = true
            self.leadingViewController?.view.isHidden = false
            self.dockViewController?.view.isHidden = false
            self.trailingViewController?.view.isHidden = false
            
            mapView?.removeGestureRecognizer(tapGesture!)
            
        } else {
            isContentViewSwitched = true
            let savedcontentvc = contentViewController

            
            UIView.animate(withDuration: 0.2, animations: {
                self.mapView?.frame = CGRect(x: -UIScreen.main.bounds.width + (self.previewViewController?.view.frame.width)! + 52, y: -275, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/2)
            }) { (_) in
                self.previewViewController = self.fpvViewController
                
                let newContentViewController = self.mymapviewController
                self.oldContentViewController = self.contentViewController as! DUXFPVViewController
                self.contentViewController = newContentViewController
                
                self.previewViewController?.view.addGestureRecognizer(self.videoTapRecognizer!)
                
                self.focusBtn?.isHidden = false
                self.mapTypeBtn?.isHidden = false
                self.gsButtonVC?.view.isHidden = false
                self.leadingViewController?.view.isHidden = true
                self.dockViewController?.view.isHidden = true
                self.trailingViewController?.view.isHidden = true
                
                self.mapView?.addGestureRecognizer(self.tapGesture!)
            }
            
            
            
        }

    }
    
    func registerApp() {
        DJISDKManager.registerApp(with: self)
    }
    
    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("starting connection")
            DJISDKManager.startConnectionToProduct()
        }
    }

    func productConnected(_ product: DJIBaseProduct?) {
        if let _ = product {
            if DJISDKManager.product()!.isKind(of: DJIAircraft.self) {
                print("connected to aircraft")
                let flightController = (DJISDKManager.product()! as! DJIAircraft).flightController!
                flightController.delegate = self
                let camera: DJICamera? = fetchCamera()
                if camera != nil {
                    camera?.delegate = self
                }
//                DJIVideoPreviewer.instance().setView(fpvViewController.fpvView)
//                DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
//                DJIVideoPreviewer.instance().start()

            }
        }
    }
    
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        droneLocation = state.aircraftLocation?.coordinate
        if let droneLoc = droneLocation {
            mapController.updateAircraftLocation(droneLoc, with: mapView)
        }
        let radianYaw = GLKMathDegreesToRadians(Float((state.attitude.yaw)))
        mapController.updateAircraftHeading(radianYaw)
    }
    
    func fetchCamera() -> DJICamera? {
        
        if !(DJISDKManager.product() != nil) {
            return nil
        }
        if (DJISDKManager.product() is DJIAircraft) {
            return (DJISDKManager.product() as? DJIAircraft)?.camera
        }
        return nil
    }
    
    //MARK:- CLLocationManger Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        if let coordinate = location?.coordinate {
            userLocation = coordinate
        }
    }
    
    @objc func focusMap() {
        if CLLocationCoordinate2DIsValid(userLocation!) {
            var region: MKCoordinateRegion {
                let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                return MKCoordinateRegion(center: userLocation!, span: span)
            }
            
            mapView?.setRegion(region, animated: true)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("annotation: ", annotation)
        if annotation is DJIAircraftAnnotation {
            let annoView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as? DJIAircraftAnnotation)?.annotationView = annoView
            return annoView
        } else if annotation is MKUserLocation {
            return nil
        } else if annotation is MKPointAnnotation {
            let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Marker_Annotation")
            markerView.animatesWhenAdded = true
            markerView.markerTintColor = .purple
            markerView.glyphText = annotation.title!
        
            return markerView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.yellow
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view is MKMarkerAnnotationView {
            print("selected waypoint: \(String(describing: view.annotation?.title))")
        }
    }
    
    @objc func showMoreInfo(_ sender: UIButton){
        print("show popover to show more info")
        let alert = UIAlertController(title: "Alert", message: "My Alert for test", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            print("you have pressed the ok button")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        for annotation in (mapView?.selectedAnnotations)! {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 25))
            label.text = "Altitude: 55m"
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Marker_Annotation")
            marker.detailCalloutAccessoryView = label
            
        }
    }
    
    @objc func addWaypoints(_ tapGesture: UITapGestureRecognizer?) {
        print("tapped in mapview")
        let point: CGPoint? = tapGesture?.location(in: mapView)
        
        if tapGesture?.state == .ended {
            
            if isEditingPoints {
                mapController.add(point!, with: mapView)
                gsButtonVC?.clearItem.isHidden = false
                if mapController.wayPoints().count == 1 {
                    gsButtonVC?.floaty.close()
                    gsButtonVC?.floaty.open()
                }
                print("added point")
                var waypointNum:[Int] = [1]
                waypointNum.append(waypointNum.last! + 1)
            }
        }
    }
    
    func missionOperator() -> DJIWaypointMissionOperator? {
        return DJISDKManager.missionControl()?.waypointMissionOperator()
    }
    
    func showAlertView(withTitle title: String?, withMessage message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    
    func startMission() {
        missionOperator()?.startMission(completion: { error in
            if error != nil {
                print("Start Mission Failed", error?.localizedDescription as Any)
            } else {
                print("", "Mission Started")
            }
        })
    }
}

extension DefaultLayoutViewController: DJIVideoFeedListener, DJICameraDelegate {
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        
        let data = NSData(data: videoData)
        var video = videoData
        video.withUnsafeMutableBytes { (pointer: UnsafeMutablePointer<UInt8>) in
            DJIVideoPreviewer.instance().push(pointer, length: Int32(data.length))
        }
    }
    
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {

    }
}

extension DefaultLayoutViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DefaultLayoutViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
