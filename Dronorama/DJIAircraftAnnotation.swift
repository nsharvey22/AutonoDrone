//
//  DJIAircraftAnnotation.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/8/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DJIAircraftAnnotation: NSObject, MKAnnotation {
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    weak var annotationView: DJIAircraftAnnotationView?
    
    init(coordiante coordinate: CLLocationCoordinate2D) {
        //super.init()
        self.coordinate = coordinate
    }
    
    func setCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
    }
    
    func updateHeading(_ heading: Float) {
        if (annotationView != nil) {
            annotationView?.updateHeading(heading)
        }
    }
    
}
