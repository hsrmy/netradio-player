//
//  LanchScreenController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/6.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import Foundation
import Reachability
import SwiftGifOrigin

class LanchScreenController: UIViewController {
    let dow = ["sun","mon","tue","wed","thu","fri","sat"]
    var progressBar: UIProgressView! = nil
    let reachability = Reachability()!
    var delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    var picarray:[String:Data]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = UIColor.white
        if defaults.dictionary(forKey: "onsenimage") == nil {
            defaults.set([String:Data](), forKey: "onsenimage")
        }
        if defaults.dictionary(forKey: "hibikiImage") == nil {
            defaults.set([String:Data](), forKey: "hibikiImage")
        }
        // ネットワーク接続がある時
        reachability.whenReachable = { reachability in
            self.setUI()
            DispatchQueue.global().async {
                self.getAgqr()
                DispatchQueue.main.async {
                    self.progressBar.setProgress(0.33, animated: true)
                }
                self.getOnsen()
                DispatchQueue.main.async {
                    self.progressBar.setProgress(0.66, animated: true)
                }
                self.gethibiki()
                DispatchQueue.main.async {
                    self.progressBar.setProgress(0.99, animated: true)
                }
                DispatchQueue.main.async {
                    let next = ViewController()
                    let navi = UINavigationController(rootViewController: next)
                    self.present(navi, animated: false, completion: nil)
                }
            }
        }
        
        // ネットワーク接続が無い時
        reachability.whenUnreachable = { _ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "ネットワーク接続がありません"
            alert.message = "起動に必要なデータを取得することができませんでした。\nネットワーク接続があることを確認してください。"
            alert.addAction(UIAlertAction(title: "終了",style: .default,handler: {
                (action:UIAlertAction!) -> Void in exit(0)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        // 以下5行はネットワーク接続の検知に必要
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    } // viewDidLoad
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUI() {
        // 画面の大きさよりー回り小さいviewを定義
        let loadingView = UIView(frame: CGRect(x: self.view.frame.width/10, y: self.view.frame.height/10, width: (self.view.frame.width/10)*8, height: (self.view.frame.height/10)*8))
        self.view.addSubview(loadingView) // 画面の大きさよりー回り小さいviewをセット
        
        let image = UIImageView(image: UIImage.gif(asset: "loading"))
        image.center = CGPoint(x: loadingView.bounds.width/2, y: (loadingView.bounds.height/2))
        loadingView.addSubview(image)
        
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.frame = image.frame
        progressBar.center = CGPoint(x: image.center.x, y: image.frame.maxY+15)
        loadingView.addSubview(progressBar) // プログレスバーのセット
        
        let leftLabel = UILabel(frame: CGRect(x: image.frame.minX, y: image.frame.maxY+30, width: image.frame.width, height: 30))
        leftLabel.text = "起動中です"
        leftLabel.textAlignment = .left
        
        let rightLabel = UILabel(frame: CGRect(x: image.frame.minX, y: image.frame.maxY+30, width: image.frame.width, height: 30))
        rightLabel.text = "しばらくお待ち下さい..."
        rightLabel.textAlignment = .right
        
        loadingView.addSubview(leftLabel)
        loadingView.addSubview(rightLabel)
    }
    
    func getAgqr() {
        struct List: Codable {
            var sun: [data]
            var mon: [data]
            var tue: [data]
            var wed: [data]
            var thu: [data]
            var fri: [data]
            var sat: [data]
            struct data: Codable {
                var title: String
                var person: String
                var start: String
                var end: String
            }
        }
        
        let url = URL(string: "https://www.emradc.xyz/api/agqr")!
        do {
            let json = try String(contentsOf: url)
            let decode = try JSONDecoder().decode(List.self, from: json.data(using: .utf8)!)
            var agqrinfo:[String:[[String]]] = [String:[[String]]]()
            for day in dow {
                if agqrinfo[day] == nil {
                    agqrinfo[day] = []
                }
                switch day {
                case "sun":
                    for prog in decode.sun {
                        agqrinfo[day]?.append([prog.title,prog.person,prog.start,prog.end])
                    }
                case "mon":
                    for prog in decode.mon {
                        agqrinfo[day]?.append([prog.title,prog.person,prog.start,prog.end])
                    }
                case "tue":
                    for prog in decode.tue {
                        agqrinfo[day]?.append([prog.title,prog.person,prog.start,prog.end])
                    }
                case "wed":
                    for prog in decode.wed {
                        agqrinfo[day]?.append([prog.title,prog.person,prog.start,prog.end])
                    }
                case "thu":
                    for prog in decode.thu {
                        agqrinfo[day]?.append([prog.title,prog.person,prog.start,prog.end])
                    }
                case "fri":
                    for prog in decode.fri {
                        agqrinfo[day]?.append([prog.title,prog.person,prog.start,prog.end])
                    }
                case "sat":
                    for prog in decode.sat {
                        agqrinfo[day]?.append([prog.title,prog.person,prog.start,prog.end])
                    }
                default:
                    print("convert error")
                }
            }
            delegate.agqrinfo = agqrinfo
        } catch {
            print(error)
        }
    }
    
    func getOnsen() {
        struct List: Codable {
            var mon: [data]
            var tue: [data]
            var wed: [data]
            var thu: [data]
            var fri: [data]
            var sat: [data]
            struct data: Codable {
                var name: String
                var cast: String
                var id: String
                var description: String
                var image: String
                var count: String
                var video_url: String
            }
        }
        
        let url = URL(string: "https://www.emradc.xyz/api/onsen")!
        do {
            let json = try String(contentsOf: url)
            let decode = try JSONDecoder().decode(List.self, from: json.data(using: .utf8)!)
            var onseninfo:[String:[[String]]] = [String:[[String]]]()
            if defaults.dictionary(forKey: "picarray") == nil {
                self.picarray = [:]
            } else {
                self.picarray = defaults.dictionary(forKey: "picarray") as? [String:Data]
            }
            
            for day in dow {
                switch day {
                case "sun":
                    break
                case "mon":
                    if onseninfo[day] == nil {
                        onseninfo[day] = []
                    }
                    for prog in decode.mon {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_url,prog.image,prog.count]
                        onseninfo[day]?.append(data)
                        if self.picarray["onsen-\(prog.id)"] == nil {
                            self.picarray["onsen-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "tue":
                    if onseninfo[day] == nil {
                        onseninfo[day] = []
                    }
                    for prog in decode.tue {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_url,prog.image,prog.count]
                        onseninfo[day]?.append(data)
                        if self.picarray["onsen-\(prog.id)"] == nil {
                            self.picarray["onsen-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "wed":
                    if onseninfo[day] == nil {
                        onseninfo[day] = []
                    }
                    for prog in decode.wed {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_url,prog.image,prog.count]
                        onseninfo[day]?.append(data)
                        if self.picarray["onsen-\(prog.id)"] == nil {
                            self.picarray["onsen-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "thu":
                    if onseninfo[day] == nil {
                        onseninfo[day] = []
                    }
                    for prog in decode.thu {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_url,prog.image,prog.count]
                        onseninfo[day]?.append(data)
                        if self.picarray["onsen-\(prog.id)"] == nil {
                            self.picarray["onsen-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "fri":
                    if onseninfo[day] == nil {
                        onseninfo[day] = []
                    }
                    for prog in decode.fri {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_url,prog.image,prog.count]
                        onseninfo[day]?.append(data)
                        if self.picarray["onsen-\(prog.id)"] == nil {
                            self.picarray["onsen-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "sat":
                    if onseninfo[day] == nil {
                        onseninfo[day] = []
                    }
                    for prog in decode.sat {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_url,prog.image,prog.count]
                        onseninfo[day]?.append(data)
                        if self.picarray["onsen-\(prog.id)"] == nil {
                            self.picarray["onsen-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                default:
                    print("convert error")
                }
            }
            delegate.onseninfo = onseninfo
            defaults.set(picarray, forKey: "picarray")
            defaults.synchronize()
        } catch {
            print(error)
        }
    }
    
    func gethibiki() {
        struct List: Codable {
            var mon: [data]
            var tue: [data]
            var wed: [data]
            var thu: [data]
            var fri: [data]
            var sat: [data]
            struct data: Codable {
                var name: String
                var cast: String
                var id: String
                var description: String
                var image: String
                var video_id: String
            }
        }
        
        let url = URL(string: "https://www.emradc.xyz/api/hibiki")!
        do {
            let json = try String(contentsOf: url)
            let decode = try JSONDecoder().decode(List.self, from: json.data(using: .utf8)!)
            var hibikiInfo:[String:[[String]]] = [String:[[String]]]()
            if defaults.dictionary(forKey: "picarray") == nil {
                self.picarray = [:]
            } else {
                self.picarray = defaults.dictionary(forKey: "picarray") as? [String:Data]
            }
            for day in dow {
                switch day {
                case "sun":
                    break
                case "mon":
                    if hibikiInfo[day] == nil {
                        hibikiInfo[day] = []
                    }
                    for prog in decode.mon {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_id,prog.image]
                        hibikiInfo[day]?.append(data)
                        if self.picarray["hibiki-\(prog.id)"] == nil {
                            self.picarray["hibiki-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "tue":
                    if hibikiInfo[day] == nil {
                        hibikiInfo[day] = []
                    }
                    for prog in decode.tue {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_id,prog.image]
                        hibikiInfo[day]?.append(data)
                        if self.picarray["hibiki-\(prog.id)"] == nil {
                            self.picarray["hibiki-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "wed":
                    if hibikiInfo[day] == nil {
                        hibikiInfo[day] = []
                    }
                    for prog in decode.wed {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_id,prog.image]
                        hibikiInfo[day]?.append(data)
                        if self.picarray["hibiki-\(prog.id)"] == nil {
                            self.picarray["hibiki-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "thu":
                    if hibikiInfo[day] == nil {
                        hibikiInfo[day] = []
                    }
                    for prog in decode.thu {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_id,prog.image]
                        hibikiInfo[day]?.append(data)
                        if self.picarray["hibiki-\(prog.id)"] == nil {
                            self.picarray["hibiki-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "fri":
                    if hibikiInfo[day] == nil {
                        hibikiInfo[day] = []
                    }
                    for prog in decode.fri {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_id,prog.image]
                        hibikiInfo[day]?.append(data)
                        if self.picarray["hibiki-\(prog.id)"] == nil {
                            self.picarray["hibiki-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                case "sat":
                    if hibikiInfo[day] == nil {
                        hibikiInfo[day] = []
                    }
                    for prog in decode.sat {
                        let data = [prog.id,prog.name,prog.cast,prog.description,prog.video_id,prog.image]
                        hibikiInfo[day]?.append(data)
                        if self.picarray["hibiki-\(prog.id)"] == nil {
                            self.picarray["hibiki-\(prog.id)"] = getPic(url: prog.image)
                        }
                    }
                default:
                    print("convert error")
                }
            }
            delegate.hibikiInfo = hibikiInfo
            defaults.set(picarray, forKey: "picarray")
            defaults.synchronize()
        } catch {
            print(error)
        }
    }
    
    func getPic(url: String) -> Data {
        let thumbnail: Data = try! Data(contentsOf: URL(string: url)!)
        return thumbnail
    }

}
