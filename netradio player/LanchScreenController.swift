//
//  LanchScreenController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/6.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import Foundation
import Fuzi

class LanchScreenController: UIViewController {
    let dow = ["mon","tue","wed","thu","fri","sat"]
    var onsenlist: [String:Array<Any>]!
    var onseninfo: [String:Array<Any>]!
    var hibikilist: [String:Array<String>]!
    var hibikiInfo: [String:Array<Any>]!
    
    var progressBar: UIProgressView! = nil
    var loadingView: UIView!
    var waitlabel: UILabel!
    var indicator: UIActivityIndicatorView!
    var detail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = UIColor.white
        let defaults = UserDefaults.standard

        // 日付の変換
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        // 画面の大きさよりー回り小さいviewを定義
        loadingView = UIView()
        loadingView.frame = CGRect(x: self.view.frame.width/10, y: self.view.frame.height/10, width: (self.view.frame.width/10)*8, height: (self.view.frame.height/10)*8)
        setIndicator() // indicatorの定義
        setwaitLabel() // ラベルの定義
        setprogressBar() // プログレスバーの定義
        setdetailLabel() // ラベルの定義
        
        self.view.addSubview(loadingView) // 画面の大きさよりー回り小さいviewをセット
        loadingView.addSubview(indicator) // indicatorのセット
        loadingView.addSubview(progressBar) // ラベルのセット
        loadingView.addSubview(waitlabel) // プログレスバーのセット
        loadingView.addSubview(detail) // ラベルのセット
        indicator.startAnimating()
        
        DispatchQueue.global().async {
            if defaults.bool(forKey: "hasLaunch") == false { // 初回起動時
                if defaults.bool(forKey: "onsen_skip") == false {
                    self.onsenlist = self.getOnsenList()
                    DispatchQueue.main.async {
                        self.detail.text = "音泉の番組一覧を取得完了 (2/5)"
                        self.progressBar.setProgress(0.4, animated: true)
                    } // L.57
                    self.onseninfo = [String:Array<Any>]()
                    for day in self.dow {
                        for i in (0...((self.onsenlist[day]?.count)!-1)) {
                            let name = self.onsenlist[day]?[i] as! String
                            let data = self.getOnsenInfo(name)
                            if self.onseninfo[name] == nil {
                                self.onseninfo[name] = []
                            } // L.66
                            self.onseninfo[name]? = data
                        } // L.63
                    } // L.62
                    DispatchQueue.main.async {
                        self.detail.text = "音泉の番組情報を取得完了 (3/5)"
                        self.progressBar.setProgress(0.6, animated: true)
                        // データをダウンロードしてきた日付を保存
                        defaults.set(formatter.string(from: Date()), forKey: "whenOnsenDownload")
                        defaults.set(self.onsenlist, forKey: "onsenlist") // 音泉の番組一覧を保存
                        defaults.set(self.onseninfo, forKey: "onseninfo") // 音泉の番組詳細を保存
                    } // L.72
                }
                if defaults.bool(forKey: "hibiki_skip") == false { // L.55
                    self.hibikilist = self.getHibikiList()
                    DispatchQueue.main.async {
                        self.detail.text = "響の番組情報を取得完了 (4/5)"
                        self.progressBar.setProgress(0.8, animated: true)
                    } // L.78
                    self.hibikilist = self.getHibikiList()
                    self.hibikiInfo = [String:Array<Any>]()
                    for i in (1...6) {
                        let day = i.description
                        for j in (0...(self.hibikilist[day]?.count)!-1) {
                            let name: String = (self.hibikilist[day]?[j])!
                            let data = self.getHibikiInfo(id: name)
                            if data.isEmpty == false {
                                if self.hibikiInfo[name] == nil {
                                    self.hibikiInfo[name] = []
                                } // L.89
                                self.hibikiInfo[name] = data
                            }
                        } // L.86
                    } // L.84
                    DispatchQueue.main.async {
                        self.detail.text = "響の番組情報を取得完了 (5/5)"
                        self.progressBar.setProgress(1.0, animated: true)
                        // データをダウンロードしてきた日付を保存
                        defaults.set(formatter.string(from: Date()), forKey: "whenHibikiDownload")
                        defaults.set(self.hibikilist, forKey: "hibikilist") // 響の番組一覧を保存
                        defaults.set(self.hibikiInfo, forKey: "hibikiInfo") // 響の番組詳細を保存
                    } //L.95
                } // L.76
                
                DispatchQueue.main.async {
                    defaults.set(true, forKey: "hasLaunch") //  初回起動処理が完了している事を保存
                    self.indicator.stopAnimating()
                    let next = ViewController()
                    let navi = UINavigationController(rootViewController: next)
                    self.present(navi, animated: false, completion: nil)
                }
                print(self.hibikiInfo)
            } else { // 2回目以降 // L.54
                var getonsen = false
                var gethibiki = false
                let settingonsen = Date(timeIntervalSinceNow: TimeInterval(-60*60*24*defaults.integer(forKey: "onsen_time")))
                let latestonsen = formatter.date(from: defaults.string(forKey: "whenOnsenDownload")!)
                if settingonsen < latestonsen! { // 音泉の最終データ取得日が設定で設定された日数を超えている場合
                    if defaults.bool(forKey: "onsen_skip") == false { // デバックモード・音泉取得スキップがOFFの場合
                        getonsen = true
                        
                    } // L.116
                } // L.115
                let settinghibiki = Date(timeIntervalSinceNow: TimeInterval(-60*60*24*defaults.integer(forKey: "hibiki_time")))
                let latesthibiki = formatter.date(from: defaults.string(forKey: "whenHibikiDownload")!)
                if settinghibiki < latesthibiki! { // 響の最終データ取得日が設定で設定された日数を超えている場合
                    if defaults.bool(forKey: "hibiki_skip") == false { // デバックモード・響取得スキップがOFFの場合
                        gethibiki = true
                        
                    } // L.124
                } // L.123
                
                if getonsen == true && gethibiki == true {
                    self.onsenlist = self.getOnsenList()
                    DispatchQueue.main.async {
                        self.detail.text = "音泉の番組一覧を取得完了 (1/4)"
                        self.progressBar.setProgress(0.25, animated: true)
                    }
                    self.onseninfo = [String:Array<Any>]()
                    for day in self.dow {
                        for i in (0...((self.onsenlist[day]?.count)!-1)) {
                            let name = self.onsenlist[day]?[i] as! String
                            let data = self.getOnsenInfo(name)
                            if self.onseninfo[name] == nil {
                                self.onseninfo[name] = []
                            }
                            self.onseninfo[name]? = data
                        }
                    }
                    DispatchQueue.main.async {
                        self.detail.text = "音泉の番組情報を取得完了 (2/4)"
                        self.progressBar.setProgress(0.5, animated: true)
                    }
                    self.hibikilist = self.getHibikiList()
                    DispatchQueue.main.async {
                        self.detail.text = "響の番組情報を取得完了 (3/4)"
                        self.progressBar.setProgress(0.75, animated: true)
                    }
                    self.hibikilist = self.getHibikiList()
                    self.hibikiInfo = [String:Array<Any>]()
                    for i in (1...6) {
                        let day = i.description
                        for j in (0...(self.hibikilist[day]?.count)!-1) {
                            let name: String = (self.hibikilist[day]?[j])!
                            let data = self.getHibikiInfo(id: name)
                            if data.isEmpty == false {
                                if self.hibikiInfo[name] == nil {
                                    self.hibikiInfo[name] = []
                                }
                                self.hibikiInfo[name] = data
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.detail.text = "響の番組情報を取得完了 (4/4)"
                        self.progressBar.setProgress(1.0, animated: true)
                    }
                    defaults.set(formatter.string(from: Date()), forKey: "whenHibikiDownload")
                    defaults.set(formatter.string(from: Date()), forKey: "whenOnsenDownload")
                    defaults.set(self.onsenlist, forKey: "onsenlist") // 音泉の番組一覧を保存
                    defaults.set(self.onseninfo, forKey: "onseninfo") // 音泉の番組詳細を保存
                    defaults.set(self.hibikilist, forKey: "hibikilist") // 響の番組一覧を保存
                    defaults.set(self.hibikiInfo, forKey: "hibikiInfo") // 響の番組詳細を保存
                } else if getonsen == true && gethibiki == false {
                    self.onsenlist = self.getOnsenList()
                    DispatchQueue.main.async {
                        self.detail.text = "音泉の番組一覧を取得完了 (1/2)"
                        self.progressBar.setProgress(0.5, animated: true)
                    }
                    self.onseninfo = [String:Array<Any>]()
                    for day in self.dow {
                        for i in (0...((self.onsenlist[day]?.count)!-1)) {
                            let name = self.onsenlist[day]?[i] as! String
                            let data = self.getOnsenInfo(name)
                            if self.onseninfo[name] == nil {
                                self.onseninfo[name] = []
                            }
                            self.onseninfo[name]? = data
                        }
                    }
                    DispatchQueue.main.async {
                        self.detail.text = "音泉の番組情報を取得完了 (2/2)"
                        self.progressBar.setProgress(1.0, animated: true)
                    }
                    
                    defaults.set(formatter.string(from: Date()), forKey: "whenOnsenDownload")
                    defaults.set(self.onsenlist, forKey: "onsenlist") // 音泉の番組一覧を保存
                    defaults.set(self.onseninfo, forKey: "onseninfo") // 音泉の番組詳細を保存
                } else if getonsen == false && gethibiki == true {
                    self.hibikilist = self.getHibikiList()
                    DispatchQueue.main.async {
                        self.detail.text = "響の番組情報を取得完了 (3/4)"
                        self.progressBar.setProgress(0.8, animated: true)
                    }
                    self.hibikilist = self.getHibikiList()
                    self.hibikiInfo = [String:Array<Any>]()
                    for i in (1...6) {
                        let day = i.description
                        for j in (0...(self.hibikilist[day]?.count)!-1) {
                            let name: String = (self.hibikilist[day]?[j])!
                            let data = self.getHibikiInfo(id: name)
                            if self.hibikiInfo[name] == nil {
                                self.hibikiInfo[name] = []
                            }
                            self.hibikiInfo[name] = data
                        }
                    }
                    DispatchQueue.main.async {
                        self.detail.text = "響の番組情報を取得完了 (4/4)"
                        self.progressBar.setProgress(1.0, animated: true)
                    }
                    defaults.set(self.hibikilist, forKey: "hibikilist") // 響の番組一覧を保存
                    defaults.set(self.hibikiInfo, forKey: "hibikiInfo") // 響の番組詳細を保存
                    defaults.set(formatter.string(from: Date()), forKey: "whenHibikiDownload")
                }
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    let next = ViewController()
                    let navi = UINavigationController(rootViewController: next)
                    self.present(navi, animated: false, completion: nil)
                }
            } // L.110
        } //L.53
    } // viewDidLoad
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setwaitLabel() {
        waitlabel = UILabel()
        waitlabel.textAlignment = .center
        waitlabel.frame = loadingView.bounds
        waitlabel.numberOfLines = 0
        waitlabel.center = CGPoint(x: loadingView.bounds.width/2, y: indicator.center.y-100)
        waitlabel.text = "起動中です\n必要なデータをダウンロードしてます\nしばらくお待ち下さい"
    }
    
    func setIndicator() {
        indicator = UIActivityIndicatorView() // ローディングの時のクルクル回るやつ
        indicator.frame = loadingView.bounds
        indicator.center = CGPoint(x: loadingView.bounds.width/2, y: (loadingView.bounds.height/2)+40)
        indicator.style = UIActivityIndicatorView.Style.whiteLarge // 大きな白色
        indicator.color = UIColor.blue
        indicator.hidesWhenStopped = true // アニメーション停止と同時に隠す設定
    }
    
    func setprogressBar() {
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.frame = loadingView.bounds
        progressBar.center = CGPoint(x: loadingView.bounds.width/2, y: indicator.center.y+50)
        progressBar.backgroundColor = UIColor.red
    }
    
    func setdetailLabel() {
        detail = UILabel()
        detail.textAlignment = .center
        detail.frame = loadingView.bounds
        detail.center = CGPoint(x: loadingView.bounds.width/2, y: indicator.center.y+100)
        detail.numberOfLines = 0
        detail.text = "進捗: -"
    }
    
    func getOnsenList() -> [String:Array<Any>] {
        var proglist = [String:Array<Any>]()
        
        let url = URL(string: "http://www.onsen.ag")!
        do {
            let html = try String(contentsOf: url)
            do {
                // 取得したhtmlをパースできるようにする
                let document = try HTMLDocument(string: html, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                // class="listWrap"->class="clr"->li
                var list = [String:Array<Any>]()
                for element in document.css(".listWrap .clr li"){
                    let name:String = element.attr("id")! // 属性idの属性値を代入
                    let week:String = element.attr("data-week")! // 属性data-weekの属性値を代入
                    if list[week] == nil {
                        list[week] = []
                    }
                    list[week]?.append(name)
                }
                proglist = list
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        
        return proglist
    }
    
    let getOnsenInfo = { (name:String) -> ([Any]) in
        let url = URL(string: "http://www.onsen.ag/data/api/getMovieInfo/\(name)")!
        var list = Array<Any>()
        do {
            // 取得してきたJSONPからJSONに変換
            let json = try String(contentsOf: url).replacingOccurrences(of: "callback(", with: "").replacingOccurrences(of: ");", with: "")
            
            struct List: Codable {
                var thumbnailPath: String
                var moviePath: moviePath
                var title: String
                var personality: String
                
                struct moviePath: Codable {
                    var pc: String
                }
            }
            
            do {
                let decode = try JSONDecoder().decode(List.self, from: json.data(using: .utf8)!)
                let thumbnail: Data = try! Data(contentsOf: URL(string: "http://www.onsen.ag\(decode.thumbnailPath)")!)
                list = [decode.title,decode.personality,decode.moviePath.pc,thumbnail] as [Any]
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        return list
    }
    
    // 響の番組一覧取得関数
    func getHibikiList() -> [String:Array<String>] {
        var list = [String:Array<String>]()
        struct List:Codable {
            var day_of_week: Int
            var access_id: String
            var latest_episode_id: Int?
        }
        
        let condition = NSCondition()
        let listurl = URL(string: "https://vcms-api.hibiki-radio.jp/api/v1/programs")
        var request = URLRequest(url: listurl!)
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.addValue("http://hibiki-radio.jp", forHTTPHeaderField: "Origin")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            condition.lock()
            if let data = data, let response = response as? HTTPURLResponse, error == nil {
                if response.statusCode == 200 {
                    let rawdata = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    var tmp  = [String:Array<String>]()
                    do {
                        let decode:[List] = try JSONDecoder().decode([List].self, from: rawdata.data(using: .utf8)! )
                        for prog in decode{
                            if prog.latest_episode_id != nil {
                                let dow = prog.day_of_week.description
                                let access_id = prog.access_id
                                if tmp[dow] == nil {
                                    tmp[dow] = []
                                }
                                tmp[dow]?.append(access_id)
                            }
                        }
                        list = tmp
                    } catch {
                        print("error:\(error.localizedDescription)")
                    }
                }
            } else {
                print("error:\(String(describing: error?.localizedDescription))")
            }
            condition.signal()
            condition.unlock()
        })
        condition.lock()
        task.resume()
        condition.wait()
        condition.unlock()
        
        return list
    }
    
    // 響の番組情報取得関数
    func getHibikiInfo(id: String) -> [Any] {
        var list = [Any]()
        struct Info: Codable {
            var name: String
            var description: String
            var cast: String
            var sp_image_url: String
            var episode: episode
            
            struct episode: Codable {
                var video: video?
            }
            
            struct video: Codable {
                var id: Int?
            }
        }
        
        let condition = NSCondition()
        let infourl = URL(string: "https://vcms-api.hibiki-radio.jp/api/v1/programs/\(id)")
        var request = URLRequest(url: infourl!)
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.addValue("http://hibiki-radio.jp", forHTTPHeaderField: "Origin")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            condition.lock()
            if let data = data, let response = response as? HTTPURLResponse, error == nil {
                if response.statusCode == 200 {
                    let rawdata = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    do {
                        let decode = try JSONDecoder().decode(Info.self, from: rawdata.data(using: .utf8)! )
                        let video_id: String = decode.episode.video?.id?.description ?? ""
                        let description = decode.description.replacingOccurrences(of: "\r\n", with: "\n")
                        let thumbnail: Data = try! Data(contentsOf: URL(string: decode.sp_image_url)!)
                        list = [decode.name,decode.cast,description,video_id,thumbnail]
                    } catch {
                        print("error with \(id): \(error)")
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
        
        return list
    }

}
