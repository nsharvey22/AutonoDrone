//
//  FPVViewController.swift
//  Dronorama
//
//  Created by Nick Harvey on 3/9/19.
//  Copyright © 2019 Nick Harvey. All rights reserved.
//

import UIKit
import DJISDK
import DJIUXSDK
import DJIWidget

class FPVViewController: UIViewController {

    var fpvController: DUXFPVViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFpvView()

        let camera: DJICamera? = fetchCamera()
        if camera != nil {
            camera?.delegate = self
        }
        DJIVideoPreviewer.instance().setView(self.view)
        DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        DJIVideoPreviewer.instance().start()
    }
    
    func setupFpvView() {
        self.fpvController = DUXFPVViewController()
        self.addChild(self.fpvController!)
        self.view.backgroundColor = .black
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

}

extension FPVViewController: DJIVideoFeedListener, DJICameraDelegate {
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        
        let data = NSData(data: videoData)
        var video = videoData
        video.withUnsafeMutableBytes { (pointer: UnsafeMutablePointer<UInt8>) in
            DJIVideoPreviewer.instance().push(pointer, length: Int32(data.length))
        }
    }

}
