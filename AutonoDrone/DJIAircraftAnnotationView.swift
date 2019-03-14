//
//  DJIAircraftAnnotationView.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/8/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit
import MapKit

class DJIAircraftAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        isEnabled = false
        isDraggable = false
        image = UIImage(named: "aircraft")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHeading(_ heading: Float) {
        transform = CGAffineTransform.identity
        transform = CGAffineTransform(rotationAngle: CGFloat(heading))
    }
}
