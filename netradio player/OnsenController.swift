//
//  OnsenController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/4.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import Toast_Swift
import Fuzi

class OnsenController: UIViewController, URLSessionDelegate ,URLSessionDataDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let dow = ["mon","tue","wed","thu","fri","sat"]
    let dow_jp = ["月曜日","火曜日","水曜日","木曜日","金曜日","土・日曜日"]
    var progTable: UITableView!
    let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var list: [String:Array<Any>]!
    var info: [String:Array<Any>]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        defaults.set("onsen", forKey: "last") // 音選を選局したことを保存
        defaults.synchronize()
        
        self.title = "インターネットラジオステーション＜音泉＞"
        self.view.backgroundColor = UIColor.white
    
        list = delegate.onsenList // 番組一覧のリスト
        info = delegate.onsenInfo // 番組詳細のDictionary
        
        // UI部分(ステータスバー、ナビゲーションバー、ツールバー)のサイズ
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height
        let framesize = UIScreen.main.bounds.size.height - uisize
        progTable = UITableView(frame: CGRect(x: 0, y: uisize, width: UIScreen.main.bounds.size.width, height: framesize), style: .plain)
        
        progTable.dataSource = self
        progTable.delegate = self
        
        self.view.addSubview(progTable)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange(notification:)),name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[dow[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        let name = list[dow[indexPath.section]]![indexPath.row] as! String
        cell.textLabel?.text = info[name]?[0] as? String
        cell.detailTextLabel?.text = info[name]?[1] as? String
        cell.imageView?.image = UIImage(data: (info[name]?[3] as? Data)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dow_jp.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dow_jp[section]
    }
    
    // 向きが変わったらframeをセットしなおして再描画
    @objc func onOrientationChange(notification: NSNotification){
        // UI(ステータスバーとナビゲーションバー)の高さ
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height
        let framesize = UIScreen.main.bounds.size.height - uisize // フレームの大きさの高さ
        // フレームの大きさをビューの大きさに
        progTable.frame = CGRect(x: 0, y: uisize, width: UIScreen.main.bounds.size.width, height: framesize)
        
        progTable.setNeedsLayout()
    }
    
}
