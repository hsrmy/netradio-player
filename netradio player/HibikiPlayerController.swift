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
import Reachability

class HibikiPlayerController: UIViewController {
    var id: String = ""
    var name: String = ""
    var thumbnail: Data!
    let reachability = Reachability()!
    let defaults = UserDefaults.standard
    var controller: AVPlayerViewController!
    var player: AVPlayer?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    init(id: String, name: String, thumbnail: Data) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = name
        
        reachability.whenReachable = { reachability in
            let playlist = self.getPlaylistUrl(videoid: self.id)
            let url = URL(string: playlist)
            
            let thumImage: UIImage = UIImage(data: self.thumbnail)!
            let thumLayer: CALayer = CALayer()
            let rect = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            thumLayer.frame = rect.frame
            thumLayer.contents = thumImage.cgImage
            thumLayer.contentsGravity = CALayerContentsGravity.center
            thumLayer.position = rect.center
            
            self.player = AVPlayer(url: url!)
            self.controller = AVPlayerViewController()
            self.controller.player = self.player
            self.controller.view.frame = self.view.frame
            self.controller.view.layer.addSublayer(thumLayer)
            self.view.addSubview(self.controller.view)
            self.addChild(self.controller)
            
            if self.defaults.bool(forKey: "force_wifi") == true {
                if reachability.connection == .wifi {
                    self.player?.play()
                    self.delegate.player = self.player
                    self.delegate.controller = self.controller
                } else {
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    alert.title = "Wi-Fi接続がありません"
                    alert.message = "「Wi-Fi接続時のみ再生する」がONになっているため、モバイルネットワークでは再生できません"
                    alert.addAction(UIAlertAction(title: "OK",style: .default,handler: {
                        (action:UIAlertAction!) -> Void in
                        self.controller.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                self.player?.play()
            }
        }
        
        reachability.whenUnreachable = { reachability in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "ネットワーク接続がありません"
            alert.message = "ネットワーク接続がありませんため、再生できません"
            alert.addAction(UIAlertAction(title: "OK",style: .default,handler: {
                (action:UIAlertAction!) -> Void in self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        // 以下5行はネットワーク接続の検知に必要
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
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
