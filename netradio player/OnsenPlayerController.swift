//
//  OnsenPlayerController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/22.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class OnsenPlayerController: AVPlayerViewController {
    var name: String = ""
    var url: String = ""
    var thumbnail: Data!
    
    init(name: String, url: String, thumbnail: Data) {
        self.name = name
        self.url = url
        self.thumbnail = thumbnail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        self.title = name
        let url = URL(string: self.url)
        
        let thumImage: UIImage = UIImage(data: thumbnail)!
        let thumLayer: CALayer = CALayer()
        let rect = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        thumLayer.frame = rect.frame
        thumLayer.contents = thumImage.cgImage
        thumLayer.contentsGravity = CALayerContentsGravity.center
        thumLayer.position = rect.center
        
        player = AVPlayer(url: url!)
        let controller = AVPlayerViewController()
        controller.player = player
        controller.view.frame = self.view.frame
        controller.view.layer.addSublayer(thumLayer)
        self.view.addSubview(controller.view)
        self.addChild(controller)
        player?.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
