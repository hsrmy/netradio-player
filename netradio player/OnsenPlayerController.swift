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
import Reachability
import SideMenu
import MediaPlayer

class OnsenPlayerController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var name: String = ""
    var url: String = ""
    var thumbnail: Data!
    var caption: String = ""
    var count: String = ""
    var personality: String = ""
    let reachability = Reachability()!
    let defaults = UserDefaults.standard
    var controller: AVPlayerViewController!
    var player: AVPlayer?
    var movieView: UIView!
    var infotable: UITableView!
    var toolbar: UIToolbar!
    var uisize: CGFloat!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var Text = ["タイトル","パーソナリティ","番組説明"]
    var rect: UIView!
    var image: UIImageView!
    
    init(name: String, url: String, thumbnail: Data, personality: String, caption: String, count: String) {
        self.name = name
        self.url = url
        self.thumbnail = thumbnail
        self.personality = personality
        self.caption = caption
        self.count = count
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        
        if delegate.player?.rate == 1.0 {
            delegate.player?.pause()
        }
        
        //ナビゲーションバーの設定
        self.title = "\(name) 第\(count)回"
        let drawer_button = UIBarButtonItem()
        drawer_button.image = UIImage.fontAwesomeIcon(name: .bars, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        drawer_button.target = self
        drawer_button.action = #selector(self.showDrawer)
        let back_button = UIBarButtonItem()
        back_button.image = UIImage.fontAwesomeIcon(name: .chevronLeft, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        back_button.target = self
        back_button.action = #selector(self.goback)
        self.navigationItem.leftBarButtonItems = [back_button,drawer_button]
        
        //ツールバーの設定
        toolbar = UIToolbar()
        let toolbar_y = UIScreen.main.bounds.height - (self.navigationController?.toolbar.frame.size.height)!
        toolbar.frame = CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!)
        toolbar.barStyle = .default
        
        //ツールバーの項目
        let exit = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.onTapToolbar(sender:)))
        exit.tag = 0
        
        toolbar.items = [exit]
        
        self.view.addSubview(toolbar)
        
        movieView = UIView()
        infotable = UITableView()
        
        infotable.dataSource = self
        infotable.delegate = self
        infotable.estimatedRowHeight = 50
        infotable.rowHeight = UITableView.automaticDimension
        
        let thumImage: UIImage = UIImage(data: self.thumbnail)!
        self.image = UIImageView(image: thumImage)
        
        // UI部分(ステータスバー、ナビゲーションバー、ツールバー)のサイズ
        uisize = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height + UINavigationController().toolbar.frame.size.height
        let framesize = (UIScreen.main.bounds.size.height - uisize)/2
        
        let orientation = UIDevice.current.orientation
        if (orientation.isPortrait) { //縦
            self.movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width, height: framesize)
            self.infotable.frame = CGRect(x: 0, y: framesize+uisize-UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width, height: framesize)
            self.image.center = CGPoint(x: UIScreen.main.bounds.width/2, y: (UIScreen.main.bounds.height-self.uisize)/4)
        } else if (orientation.isLandscape) { //横
            self.movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-uisize)
            self.infotable.frame = CGRect(x: UIScreen.main.bounds.size.width/2, y: uisize-UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-uisize)
            self.image.center = CGPoint(x: UIScreen.main.bounds.width/4, y: (UIScreen.main.bounds.height-self.uisize)/2)
        }
        
        let footer = UIView(frame: CGRect.zero)
        self.infotable.tableFooterView = footer
        
        self.view.addSubview(movieView)
        self.view.addSubview(infotable)
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        reachability.whenReachable = { reachability in
            let url = URL(string: self.url)
            
            self.player = AVPlayer(url: url!)
            self.controller = AVPlayerViewController()
            self.controller.player = self.player
            self.controller.view.frame.size = self.movieView.frame.size
            
            self.movieView.addSubview(self.controller.view)
            self.movieView.addSubview(self.image)
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
                self.delegate.player = self.player
                self.delegate.controller = self.controller
            }
            self.controller.updatesNowPlayingInfoCenter = false
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
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget(self, action: #selector(self.Play(event:)))
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(self.Stop(event:)))
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
            
        // Now Playing
        let artwork = MPMediaItemArtwork.init(boundsSize: thumImage.size, requestHandler: { (size) -> UIImage in
            return thumImage
        })
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: self.title!,
            MPMediaItemPropertyArtist: self.personality,
            MPMediaItemPropertyArtwork: artwork
        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange(notification:)),name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if indexPath.section == 0 {
            cell.textLabel?.text = self.title
        } else if indexPath.section == 1 {
            cell.textLabel?.text = self.personality
        } else if indexPath.section == 2 {
            cell.textLabel?.text = self.caption
            cell.textLabel?.numberOfLines = 0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Text[section]
    }
    
    @objc func Play(event: MPRemoteCommandEvent)  {
        self.player?.play()
    }
    
    @objc func Stop(event: MPRemoteCommandEvent)  {
        self.player?.pause()
    }
    
    @objc func onTapToolbar(sender: UIButton){
        switch(sender.tag){
        //終了ボタン
        case 0:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "確認"
            alert.message = "アプリを終了しますか?"
            alert.addAction(UIAlertAction(title: "はい",style: .destructive,handler: {
                (action:UIAlertAction!) -> Void in exit(0)
            }))
            alert.addAction(UIAlertAction(title: "キャンセル",style: .cancel,handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            print("error")
        }
    }
    
    @objc func showDrawer() {
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @objc func goback() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onOrientationChange(notification: NSNotification){
        // UI部分(ステータスバー、ナビゲーションバー、ツールバー)のサイズ
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height + UINavigationController().toolbar.frame.size.height
        let framesize = (UIScreen.main.bounds.size.height - uisize)/2
        
        let orientation = UIDevice.current.orientation
        if(orientation.isPortrait) { //縦
            self.movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width, height: framesize)
            self.infotable.frame = CGRect(x: 0, y: framesize+uisize-UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width, height: framesize)
            self.image.center = CGPoint(x: UIScreen.main.bounds.width/2, y: (UIScreen.main.bounds.height-self.uisize)/4)
        } else if (orientation.isLandscape) { //横
            self.movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-uisize)
            self.infotable.frame = CGRect(x: UIScreen.main.bounds.size.width/2, y: 0, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-UINavigationController().toolbar.frame.size.height)
            self.image.center = CGPoint(x: UIScreen.main.bounds.width/4, y: (UIScreen.main.bounds.height-self.uisize)/2)
        }
        let toolbar_y = self.view.bounds.size.height - (self.navigationController?.toolbar.frame.size.height)!
        self.toolbar.frame = CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!)
        
        self.movieView.setNeedsDisplay()
        self.infotable.setNeedsDisplay()
        self.toolbar.setNeedsDisplay()
    }
}
