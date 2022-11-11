//
//  VideoView.swift
//  VideoManager
//
//  Created by Admin on 20/10/22.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import UIKit

@objc(VideoView)
class VideoView: RCTViewManager {
    override class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc override func view() -> UIView! {
        return Video()
    }
}
