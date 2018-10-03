//
//  AgqrController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/4.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import Toast_Swift
import Fuzi

class AgqrController: UIViewController,UITableViewDataSource,UITableViewDelegate,URLSessionDelegate,URLSessionDataDelegate,VLCMediaPlayerDelegate  {
    
    var movieView: UIView!
    var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
    var infotable: UITableView!
    var toolbar: UIToolbar!
    var Text = ["タイトル","パーソナリティ","番組説明","番組リンク"]
    var datas: [String] = ["","","",""]
    var timer: Timer!
    var dates: [String] = []
    
    var isLock: Bool = false
    var isgot:Bool = false
    
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
        
        //ツールバーの設定
        toolbar = UIToolbar()
        let toolbar_y = UIScreen.main.bounds.height - (self.navigationController?.toolbar.frame.size.height)!
        toolbar.frame = CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!)
        toolbar.barStyle = .default
        
        //ツールバーの項目
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let exit = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.onTapToolbar(sender:)))
        exit.tag = 1
        let table = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.onTapToolbar(sender:)))
        table.tag = 2
        let buttom_reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.onTapToolbar(sender:)))
        buttom_reload.tag = 0
        let lock = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(self.onTapToolbar(sender:)))
        lock.tag = 3
        
        toolbar.items = [exit,spacer,table,spacer,buttom_reload,spacer,lock]
        
        self.view.addSubview(toolbar)
        
        movieView = UIView()
        infotable = UITableView()
        
        movieView.backgroundColor = UIColor.white
        infotable.backgroundColor = UIColor.white
        
        infotable.dataSource = self
        infotable.delegate = self
        infotable.estimatedRowHeight = 50
        infotable.rowHeight = UITableView.automaticDimension
        
        // UI部分(ステータスバー、ナビゲーションバー、ツールバー)のサイズ
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height + UINavigationController().toolbar.frame.size.height
        let framesize = (UIScreen.main.bounds.size.height - uisize)/2
        
        let orientation = UIDevice.current.orientation
        if (orientation.isPortrait) { //縦
            movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width, height: framesize)
            infotable.frame = CGRect(x: 0, y: framesize+uisize-UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width, height: framesize)
        } else if (orientation.isLandscape) { //横
            movieView.frame = CGRect(x: 0, y: uisize - UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-uisize)
            infotable.frame = CGRect(x: UIScreen.main.bounds.size.width/2, y: uisize-UINavigationController().toolbar.frame.size.height, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-uisize)
        }
        
        let footer = UIView(frame: CGRect.zero)
        self.infotable.tableFooterView = footer
        
        self.view.addSubview(movieView)
        self.view.addSubview(infotable)
        
        play()
        getProgData()
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getProgData), userInfo: nil, repeats: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange(notification:)),name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let response = dataTask.response as! HTTPURLResponse
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if response.url == URL(string: "http://www.uniqueradio.jp/aandg") {
            if (200...299).contains(response.statusCode){
                let rawdata = (String(data: data, encoding: String.Encoding.utf8) ?? "").components(separatedBy: "\n")
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
                print("\(formatter.string(from: NSDate() as Date)) Gettting program data done.")
            } else {
                self.view.makeToast("番組情報の取得に失敗しました\nしばらく待っても番組情報が表示されない場合、再読込ボタンを押してもう一度取得してください", duration: 5)
                print("\(formatter.string(from: NSDate() as Date)) Gettting program data failed.")
            }
        } else if response.url == URL(string: "http://www.agqr.jp/timetable/streaming.html"){
            let rawdata = (String(data: data, encoding: String.Encoding.utf8) ?? "")
            edithtml(html: rawdata)
        }
    }
    
    func urlSession(_ session: URLSession,task: URLSessionTask, didCompleteWithError error: Error?){
        //        let response = task.response as? HTTPURLResponse
        //        if response?.url == URL(string: "http://www.uniqueradio.jp/aandg") {
        DispatchQueue.main.async {
            self.view.makeToast("番組情報の取得に失敗しました\nしばらく待っても番組情報が表示されない場合、再読込ボタンを押してもう一度取得してください", duration: 5)
        }
        //        }
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
            self.movieView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height-UINavigationController().toolbar.frame.size.height)
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
            self.mediaPlayer.stop()
            self.mediaPlayer.play()
            self.getProgData()
        //終了ボタン
        case 1:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "確認"
            alert.message = "アプリを終了しますか?"
            alert.addAction(UIAlertAction(title: "はい",style: .default,handler: {
                (action:UIAlertAction!) -> Void in exit(0)
            }))
            alert.addAction(UIAlertAction(title: "キャンセル",style: .cancel,handler: nil))
            self.present(alert, animated: true, completion: nil)
        //ブックマークボタン
        case 2:
            print()
        //            getTimeTable()
        case 3:
            if isLock == false {
                isLock = true
            } else {
                isLock = false
            }
        default:
            print("error")
        }
    }
    
    func play() {
        //RTMPプレイヤー
        let url = URL(string: "rtmp://fms-base1.mitene.ad.jp/agqr/aandg22")
        let media = VLCMedia(url: url!)
        mediaPlayer.media = media
        mediaPlayer.delegate = self
        mediaPlayer.drawable = movieView
        mediaPlayer.play()
    }
    
    @objc func getProgData() {
        let progurl = URL(string: "http://www.uniqueradio.jp/aandg")
        let urlconfig = URLSessionConfiguration.default
        let session = URLSession(configuration: urlconfig, delegate: self as URLSessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: progurl!)
        task.resume()
    }
    
    func getTimeTable() {
        let tableurl = URL(string: "http://www.agqr.jp/timetable/streaming.html")
        let urlconfig = URLSessionConfiguration.default
        let session = URLSession(configuration: urlconfig, delegate: self as URLSessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: tableurl!)
        task.resume()
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
    
    func edithtml(html:String) {
        do {
            if isgot == false {
                let document = try HTMLDocument(string: html, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                for thead in document.css("thead"){
                    for td in thead.css("td") {
                        dates.append(td.stringValue)
                    }
                }
            }
        } catch {
            print("error when parser html")
        }
        isgot = true
        let alert = UIAlertController(title:"番組表", message: "", preferredStyle: UIAlertController.Style.alert)
        for date in dates {
            let date = UIAlertAction(title: date, style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in print(date) })
            alert.addAction(date)
        }
        let close = UIAlertAction(title: "閉じる", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
}
