//
//  DemoUtility.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/7/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit
import DJISDK

class DemoUtility: NSObject {
    
    
    class func fetchFlightController() -> DJIFlightController? {
        
        if !(DJISDKManager.product() != nil) {
            return nil
        }
        if (DJISDKManager.product() is DJIAircraft) {
            return (DJISDKManager.product() as? DJIAircraft)?.flightController
        }
        return nil
    }
    
    
}
