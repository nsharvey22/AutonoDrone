//
//  DJIMapController.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/8/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit
import MapKit
import DJISDK
import DJIUXSDK
import DJIWidget


protocol DJIMapControllerDelegate {
    func dataReady()
}

class DJIMapController: NSObject {
    
    var delegate:DJIMapControllerDelegate?
    
    var editPoints: [CLLocation] = []
    
    var aircraftAnnotation: DJIAircraftAnnotation?
    
    var pointNum = 0
    
    func updateAircraftLocation(_ location: CLLocationCoordinate2D, with mapView: MKMapView?) {
        if aircraftAnnotation == nil {
            aircraftAnnotation = DJIAircraftAnnotation(coordiante: location)
            mapView?.addAnnotation(aircraftAnnotation!)
        }
        aircraftAnnotation?.setCoordinate(location)
    }
    
    func updateAircraftHeading(_ heading: Float) {
        if (aircraftAnnotation != nil) {
            aircraftAnnotation?.updateHeading(heading)
        }
    }
    
    func add(_ point: CGPoint, with mapView: MKMapView?) {
        let coordinate: CLLocationCoordinate2D? = mapView?.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
        editPoints.append(location)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "\(pointNum + 1)"
        mapView?.addAnnotation(annotation)
        pointNum += 1
        var locations = editPoints.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        mapView?.addOverlay(polyline)
        
    }
    
    func cleanAllPoints(with mapView: MKMapView?) {
        pointNum = 0
        editPoints.removeAll()
        var annos: [MKAnnotation]? = nil
        if let annotations = mapView?.annotations {
            annos = annotations
        }
        for i in 0..<(annos?.count ?? 0) {
            let ann: MKAnnotation? = annos?[i]
            if !((ann?.isEqual(aircraftAnnotation))!) {
                if let ann = ann {
                    mapView?.removeAnnotation(ann)
                }
            }
        }
    }
    
    
    func wayPoints() -> [CLLocation] {
        return editPoints
    }
    
}
