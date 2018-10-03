//
//  OnsenController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/4.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import Toast_Swift

class OnsenController: UIViewController, URLSessionDelegate ,URLSessionDataDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var progArray: [String] = [String]()
    var progTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        defaults.set("onsen", forKey: "last") // 音選を選局したことを保存
        defaults.synchronize()
        
        self.title = "インターネットラジオステーション＜音泉＞"
        self.view.backgroundColor = UIColor.white
        
        //番組情報一覧のURL
        let listurl = URL(string: "http://www.onsen.ag/api/shownMovie/shownMovie.json")
        let urlconfig = URLSessionConfiguration.default // セッション用の設定
        // chromeのユーザーエージェント
        let ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"
        urlconfig.httpAdditionalHeaders = ["User-Agent": ua] // ユーザーエージェントヘッダーの作成
        let session = URLSession(configuration: urlconfig, delegate: self as URLSessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: listurl!)
        task.resume()
        
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
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let response = dataTask.response as! HTTPURLResponse
        
        if (200...299).contains(response.statusCode){ // HTTPステータスコードが2xxの時
            struct List: Codable {
                let result: [String]
            }
            do {
                let json = try JSONDecoder().decode(List.self, from: data)
                progArray = json.result
                DispatchQueue.main.async {
                    self.progTable.reloadData()
                }
            } catch {
                print(error)
            }
        } else { // HTTPステータスコードが2xx以外の時
            DispatchQueue.main.async {
                self.view.makeToast("番組一覧の取得に失敗しました")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = progArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
