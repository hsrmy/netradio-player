//
//  ViewController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/4.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    var stationTable: UITableView! // 放送局一覧のテーブル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "open_same") == true { // 前回終了時と同じ放送局を選局するがONの場合
            if defaults.object(forKey: "last") != nil { // 前回終了時の放送局が保存されている場合
                let select = defaults.string(forKey: "last")
                if select == "agqr" { // 前回終了時の放送局がA&Gの場合
//                    let agqr = AgqrController()
//                    let navi = UINavigationController(rootViewController: agqr)
//                    self.present(navi, animated: true, completion: nil) // A&Gに飛ぶ
                } else if select == "onsen" { // 前回終了時の放送局が音泉の場合
                    setUI()//選局画面のUIを表示
                } else if select == "hibiki" { // 前回終了時の放送局が響の場合
                    setUI()//選局画面のUIを表示
                }
            } else {
                setUI()//選局画面のUIを表示
            }
        } else { // 前回終了時と同じ放送局を選局するがOFFの場合
            setUI() //選局画面のUIを表示
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange(notification:)),name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "超!A&G+" // テーブルのテキスト
            cell.imageView?.image = UIImage(named: "agqr.png") // ロゴ
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "インターネットラジオステーション＜音泉＞" // テーブルのテキスト
            cell.imageView?.image = UIImage(named: "onsen.png") // ロゴ
            cell.imageView?.backgroundColor = UIColor.black
        } else {
            cell.textLabel?.text = "響 - HiBiKi Radio Station" // テーブルのテキスト
            cell.imageView?.image = UIImage(named: "hibiki.png") // ロゴ
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
//            let agqr = AgqrController()
//            let navi = UINavigationController(rootViewController: agqr)
//            self.present(navi, animated: true, completion: nil)
        } else {
            
        }
    }
    
    // 向きが変わったらframeをセットしなおして再描画
    @objc func onOrientationChange(notification: NSNotification){
        stationTable.beginUpdates() // テーブル再描画開始
        
        // UI(ステータスバーとナビゲーションバー)の高さ
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height
        let framesize = UIScreen.main.bounds.size.height - uisize // フレームの大きさの高さ
        // フレームの大きさをビューの大きさに
        stationTable.frame = CGRect(x: 0, y: uisize, width: UIScreen.main.bounds.size.width, height: framesize)
        stationTable.rowHeight = framesize/3 // セルの高さをフレームの高さの3分の1に
        
        stationTable.endUpdates() // テーブル再描画終了
    }
    
    func setUI() {
        self.title = "放送局を選択してください" // ナビゲーションバーのタイトル
        self.view.backgroundColor = UIColor.white // 背景の色
        
        stationTable = UITableView() // 放送局一覧のテーブルを作成
        stationTable.dataSource = self
        stationTable.delegate = self
        stationTable.isScrollEnabled = false // テーブルビューのスクロールを無効にする
        
        // UI(ステータスバーとナビゲーションバー)の高さ
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height
        let framesize = UIScreen.main.bounds.size.height - uisize // フレームの大きさの高さ
        // フレームの大きさをステータスバーとナビゲーションバーを除いた部分に
        stationTable.frame = CGRect(x: 0, y: uisize, width: self.view.bounds.width, height: framesize)
        stationTable.rowHeight = framesize/3 // セルの高さをフレームの高さの3分の1に
        
        self.view.addSubview(stationTable) // テーブルのセット
    }
}

