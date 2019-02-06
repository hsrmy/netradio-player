//
//  AgqrController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/4.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Reachability
import FontAwesome_swift
import SideMenu
import MediaPlayer

class AgqrController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    var movieView: UIView!
    var infotable: UITableView!
    let reachability = Reachability()!
    var player: AVPlayer?
    var controller: AVPlayerViewController!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var toolbar: UIToolbar!
    var uisize: CGFloat!
    let table = UIBarButtonItem()
    var Text = ["タイトル","パーソナリティ","番組説明","番組リンク"]
    var datas: [String] = ["","","",""]
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let defaults = UserDefaults.standard
        defaults.set("agqr", forKey: "last") // A&Gを選局したことを保存
        defaults.synchronize()
        
        self.view.backgroundColor = UIColor.white
        
        //ナビゲーションバーの設定
        self.title = "超!A&G"
        let top_reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.onTapToolbar(sender:)))
        top_reload.tag = 0
        self.navigationItem.rightBarButtonItem = top_reload
        
        let drawer_button = UIBarButtonItem()
        drawer_button.image = UIImage.fontAwesomeIcon(name: .bars, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        drawer_button.target = self
        drawer_button.action = #selector(self.showDrawer)
        self.navigationItem.leftBarButtonItem = drawer_button
        
        //ツールバーの設定
        toolbar = UIToolbar()
        let toolbar_y = UIScreen.main.bounds.height - (self.navigationController?.toolbar.frame.size.height)!
        toolbar.frame = CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!)
        //        toolbar.barStyle = .default
        
        //ツールバーの項目
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let exit = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.onTapToolbar(sender:)))
        exit.tag = 1
        table.image = UIImage.fontAwesomeIcon(name: .table, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        table.target = self
        table.action = #selector(self.onTapToolbar(sender:))
        table.tag = 2
        let buttom_reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.onTapToolbar(sender:)))
        buttom_reload.tag = 0
        let lock = UIBarButtonItem()
        lock.image = UIImage.fontAwesomeIcon(name: .unlockAlt, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        lock.target = self
        lock.action = #selector(self.onTapToolbar(sender:))
        lock.tag = 3
        
        toolbar.items = [exit,spacer,table,spacer,buttom_reload,spacer,lock]
        
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
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        reachability.whenReachable = { reachability in
            // プレイヤー部分
            let url = URL(string: "http://ic-www.uniqueradio.jp/iphone2/3G.m3u8")
            self.player = AVPlayer(url: url!)
            self.controller = AVPlayerViewController()
            self.controller.player = self.player
            self.controller.view.frame.size = self.movieView.frame.size
            self.movieView.addSubview(self.controller.view)
            self.addChild(self.controller)
            
            self.infoUpdater()
            
            self.player?.play()
            self.delegate.player = self.player
            self.delegate.controller = self.controller
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.infoUpdater), userInfo: nil, repeats: true)
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Text[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if indexPath.section != 3 || self.datas[3] == "" || self.datas[3] == "情報がありません" {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.datas[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 {
            if self.datas[3] != "" || self.datas[3] != "情報がありません" {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alert.title = ""
                alert.message = "リンク先 \(self.datas[3]) にアクセスします"
                alert.addAction(UIAlertAction(title: "OK",style: .default,handler: {
                    (action:UIAlertAction!) -> Void in
                    UIApplication.shared.open(NSURL(string: self.datas[3])! as URL)
                }))
                alert.addAction(UIAlertAction(title: "キャンセル",style: .cancel,handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func Play(event: MPRemoteCommandEvent)  {
        self.player?.play()
    }
    
    @objc func Stop(event: MPRemoteCommandEvent)  {
        self.player?.pause()
    }
    
    // 向きが変わったらframeをセットしなおして再描画
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
        
        self.movieView.setNeedsDisplay()
        self.infotable.setNeedsDisplay()
        self.toolbar.setNeedsDisplay()
    }
    
    @objc func onTapToolbar(sender: UIButton){
        switch(sender.tag){
        //更新ボタン
        case 0:
            DispatchQueue.main.async {
                self.view.makeToast("再読込します", duration: 3)
            }
            self.player?.pause()
            self.infoUpdater()
            sleep(4)
            self.player?.play()
        //終了ボタン
        case 1:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "確認"
            alert.message = "アプリを終了しますか?"
            alert.addAction(UIAlertAction(title: "はい",style: .destructive,handler: {
                (action:UIAlertAction!) -> Void in exit(0)
            }))
            alert.addAction(UIAlertAction(title: "キャンセル",style: .cancel,handler: nil))
            self.present(alert, animated: true, completion: nil)
        //番組表ボタン
        case 2:
            let timetable = AgqrTimetableController()
            timetable.modalPresentationStyle = .popover
            timetable.preferredContentSize = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width/10)*8, height: (UIScreen.main.bounds.height/10)*7.5).size
            timetable.popoverPresentationController?.barButtonItem = table
            timetable.popoverPresentationController?.sourceRect = UIScreen.main.bounds
            timetable.popoverPresentationController?.permittedArrowDirections = .any
            timetable.popoverPresentationController?.delegate = self
            present(timetable, animated: true, completion: nil)
        // 画面向き固定
        case 3:
            print()
        default:
            print("error")
        }
    }
    
    @objc func infoUpdater() {
        // 番組情報取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        do {
            let data = try String(contentsOf: URL(string: "http://www.uniqueradio.jp/aandg")!, encoding: .utf8)
            let rawdata = data.components(separatedBy: "\n")
            self.datas[0] = self.Cast(strings: rawdata[0].components(separatedBy: " ").last!) //タイトル
            if rawdata[4].components(separatedBy: " ").last! == "" { //パーソナリティ
                self.datas[1] = "情報がありません"
            } else {
                self.datas[1] = self.Cast(strings: rawdata[4].components(separatedBy: " ").last!)
            }
            self.datas[2] = self.striphtml(text: self.Cast(strings: rawdata[3].components(separatedBy: " ").last!).replacingOccurrences(of: "<br>", with: "\n")) //説明
            if self.Cast(strings: rawdata[2].components(separatedBy: " ").last!) == "" {
                self.datas[3] = "情報がありません"
            } else {
                self.datas[3] = self.Cast(strings: rawdata[2].components(separatedBy: " ").last!)
            }
            DispatchQueue.main.async {
                self.infotable.reloadData()
            }
            print("\(formatter.string(from: NSDate() as Date)) Getting program data done.")
        } catch  {
            print(error)
        }
        
        // Now Playing
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: self.datas[0],
            MPMediaItemPropertyArtist: self.datas[1],
        ]
    }
    
    func Cast(strings:String) -> String {
        //「'」の削除
        var string = strings.replacingOccurrences(of: "'", with: "")
        //「;」の削除
        string = string.replacingOccurrences(of: ";", with: "")
        //urlデコード
        string = string.removingPercentEncoding!
        return string
    }
    
    func striphtml(text:String) -> String {
        var after = text.replacingOccurrences(of: "<br>", with: "\n")
        after = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        after = after.trimmingCharacters(in: .whitespacesAndNewlines)
        return after
    }
    
    @objc func showDrawer() {
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    // 番組表ポップアップがiPhoneで表示される場合に必要
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
