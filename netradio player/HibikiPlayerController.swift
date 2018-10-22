//
//  HibikiPlayerContoller.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/18.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class HibikiPlayerController: AVPlayerViewController {
    var id: String = ""
    var thumbnail: Data!
    
    init(id: String, thumbnail: Data) {
        self.id = id
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
        let playlist = getPlaylistUrl(videoid: id)
        let url = URL(string: playlist)
        
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

    // 響のHLSのプレイリスト取得関数
    func getPlaylistUrl(videoid: String) -> String {
        var playlist_url: String!
        struct Check:Decodable {
            var playlist_url: String
        }
        
        let condition = NSCondition()
        let checkurl = URL(string: "https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=\(videoid)")
        var request = URLRequest(url: checkurl!)
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.addValue("http://hibiki-radio.jp", forHTTPHeaderField: "Origin")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            condition.lock()
            if let data = data, let response = response as? HTTPURLResponse, error == nil {
                if response.statusCode == 200 {
                    let rawdata = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    do {
                        let decode = try JSONDecoder().decode(Check.self, from: rawdata.data(using: .utf8)! )
                        playlist_url = decode.playlist_url
                    } catch {
                        print(error)
                    }
                }
            }
            condition.signal()
            condition.unlock()
        })
        condition.lock()
        task.resume()
        condition.wait()
        condition.unlock()
        
        return playlist_url
    }
}
