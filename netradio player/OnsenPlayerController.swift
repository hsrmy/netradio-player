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
    var thumLayer: CALayer!
    
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
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let exit = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.onTapToolbar(sender:)))
        exit.tag = 0
        let lock = UIBarButtonItem()
        lock.image = UIImage.fontAwesomeIcon(name: .unlockAlt, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        lock.target = self
        lock.action = #selector(self.onTapToolbar(sender:))
        lock.tag = 1
        
        toolbar.items = [exit,spacer,lock]
        
        self.view.addSubview(toolbar)
        
        movieView = UIView()
        infotable = UITableView()
        
        infotable.dataSource = self
        infotable.delegate = self
        infotable.estimatedRowHeight = 50
        infotable.rowHeight = UITableView.automaticDimension
        
        // UI部分(ステータスバー、ナビゲーションバー、ツールバー)のサイズ
        uisize = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height + UINavigationController().toolbar.frame.size.height
        let framesize = (UIScreen.main.bounds.size.height - uisize)/2
        
        let orientation = UIDevice.current.orientation
        if (orientation.isPortrait) { //縦
            self.movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width, height: framesize)
            self.infotable.frame = CGRect(x: 0, y: framesize+uisize-UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width, height: framesize)
        } else if (orientation.isLandscape) { //横
            self.movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-uisize)
            self.infotable.frame = CGRect(x: UIScreen.main.bounds.size.width/2, y: uisize-UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-uisize)
        }
        
        let footer = UIView(frame: CGRect.zero)
        self.infotable.tableFooterView = footer
        
        self.view.addSubview(movieView)
        self.view.addSubview(infotable)
        
        reachability.whenReachable = { reachability in
            let url = URL(string: self.url)
            let thumImage: UIImage = UIImage(data: self.thumbnail)!
            self.thumLayer = CALayer()
            self.rect = UIView(frame: CGRect(x: 0, y: 0, width: self.movieView.frame.width, height: self.movieView.frame.height))
            self.thumLayer.frame = self.rect.frame
            self.thumLayer.contents = thumImage.cgImage
            self.thumLayer.contentsGravity = CALayerContentsGravity.center
            self.thumLayer.position = self.rect.center
        
            self.player = AVPlayer(url: url!)
            self.controller = AVPlayerViewController()
            self.controller.player = self.player
            self.controller.view.frame.size = self.movieView.frame.size
            self.controller.view.layer.addSublayer(self.thumLayer)
            self.movieView.addSubview(self.controller.view)
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
        // 画面向き固定
        case 1:
            if self.shouldAutorotate == true { // 画面回転をさせないようにする
                var shouldAutorotate: Bool {
                    get {
                        return false
                    }
                }
                self.view.makeToast("画面回転を固定にしました")
            } else { // 画面回転をするにする
                var shouldAutorotate: Bool {
                    get {
                        return true
                    }
                }
                self.view.makeToast("画面回転を自由にしました")
            }
        default:
            print("error")
        }
    }
    
    @objc func showDrawer() {
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @objc func goback() {
        self.player?.pause()
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
        } else if (orientation.isLandscape) { //横
            self.movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-uisize)
            self.infotable.frame = CGRect(x: UIScreen.main.bounds.size.width/2, y: 0, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-UINavigationController().toolbar.frame.size.height)
        }
        let toolbar_y = self.view.bounds.size.height - (self.navigationController?.toolbar.frame.size.height)!
        self.toolbar.frame = CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!)
        self.rect.frame = CGRect(x: 0, y: 0, width: self.movieView.frame.width, height: self.movieView.frame.height)
        self.thumLayer.frame = self.rect.frame
        
        self.movieView.setNeedsDisplay()
        self.infotable.setNeedsDisplay()
        self.toolbar.setNeedsDisplay()
    }
}
