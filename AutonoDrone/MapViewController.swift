//
//  MapViewController.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/8/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit
import DJISDK
import DJIUXSDK
import DJIWidget

class MapViewController: UIViewController {
    
    weak var mapWidget: DUXMapWidget?
    var mapWidgetController: DUXMapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMapWidget()
        
        self.mapWidget?.mapView.mapType = .hybrid
        
    }

    // MARK: - Setup
    func setupMapWidget() {
        self.mapWidgetController = DUXMapViewController()
        self.mapWidget = self.mapWidgetController?.mapWidget!
        self.mapWidget?.translatesAutoresizingMaskIntoConstraints = false
        self.mapWidgetController?.willMove(toParent: self)
        self.addChild(self.mapWidgetController!)
        self.view.addSubview(self.mapWidgetController!.mapWidget)
        self.mapWidgetController?.didMove(toParent: self)
        
        self.mapWidget?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.mapWidget?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.mapWidget?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.mapWidget?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.mapWidget?.setNeedsDisplay()
        self.view.sendSubviewToBack(self.mapWidget!)
    }
}
