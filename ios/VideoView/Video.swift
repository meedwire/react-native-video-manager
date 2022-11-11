//
//  Video.swift
//  VideoManager
//
//  Created by Admin on 20/10/22.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import AVKit

class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
        
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

class Video: UIView {
    var player: AVPlayer = AVPlayer()
    let videoPlayerLayer = PlayerView()
    
    @objc func setSource(_ val: NSString) {
        source = String(val)
    }

    override init(frame: CGRect){
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure(){
        print("Configure initilized")
        self.backgroundColor = .blue

        self.addSubview(videoPlayerLayer)

        videoPlayerLayer.frame = self.frame
        videoPlayerLayer.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        videoPlayerLayer.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        videoPlayerLayer.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        videoPlayerLayer.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 16/9).isActive = true
        videoPlayerLayer.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

//        videoPlayerLayer.player?.play()
    }
    
    var source: String {
        get {
            return "ola mundo"
        }
        set {
            let sourceFile = getSourceURL(source: newValue)
            
            let itemPLayer = AVPlayerItem(url: sourceFile)
            
            player.replaceCurrentItem(with: itemPLayer)
            
            videoPlayerLayer.player = player
        }
    }
}

