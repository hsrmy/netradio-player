//
//  SettingViewController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/23.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import UserNotifications

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let section = ["アプリの設定","アプリの情報"]
    let row = [["前回終了時と同じ放送局を選局する","Wi-Fi接続時のみに再生する","予約リストの管理"],["Version","Build"]]
    let defaults = UserDefaults.standard
    var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "設定"
        self.view.backgroundColor = UIColor.white
        
        let back_button = UIBarButtonItem()
        back_button.image = UIImage.fontAwesomeIcon(name: .chevronLeft, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        back_button.target = self
        back_button.action = #selector(self.goback)
        self.navigationItem.leftBarButtonItem = back_button
        
        table = UITableView(frame: self.view.bounds, style: .grouped)
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.dataSource = self
        table.delegate = self
        table.allowsMultipleSelection = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
        
        self.view.addSubview(table)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.row[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return section.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.1;
        } else {
            return tableView.sectionHeaderHeight;
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let defaults = UserDefaults.standard
        cell.textLabel?.text = row[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            if indexPath.row < 2 {
                let sw = UISwitch(frame: CGRect.zero)
                sw.tag = indexPath.row
                sw.addTarget(self, action: #selector(self.toggleSwitch), for: .valueChanged)
                if indexPath.row == 0 {
                    if defaults.bool(forKey: "open_same") == true {
                        sw.isOn = true
                    } else {
                        sw.isOn = false
                    }
                } else {
                    if defaults.bool(forKey: "force_wifi") == true {
                        sw.isOn = true
                    } else {
                        sw.isOn = false
                    }
                }
                cell.accessoryView = sw
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
        } else if indexPath.section == 1 {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let bundlesPath = Bundle.main.path(forResource: "Settings.bundle", ofType: nil) {
                if let plistPath = Bundle.path(forResource: "Root", ofType: "plist", inDirectory: bundlesPath) {
                    let plist = NSDictionary(contentsOfFile: plistPath)
                    let array = plist?.object(forKey: "PreferenceSpecifiers") as! NSArray
                    if indexPath.row == 0 {
                        cell.detailTextLabel?.text = (array[4] as AnyObject).value(forKey: "DefaultValue") as? String
                    } else if indexPath.row == 1 {
                        cell.detailTextLabel?.text = (array[5] as AnyObject).value(forKey: "DefaultValue") as? String
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 2{
            let reservation = ReservationEditController()
            self.navigationController?.pushViewController(reservation, animated: true)
        }
    }
    
    @objc func goback() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toggleSwitch(sender: UISwitch)  {
        if sender.tag == 0 {
            defaults.set(sender.isOn, forKey: "open_same")
        } else if sender.tag == 1 {
            defaults.set(sender.isOn, forKey: "force_wifi")
        }
        table.reloadData()
    }
    
    @objc func userDefaultsDidChange(_ notification: Notification) {
        table.reloadData()
    }
    
    deinit {
        // UserDefaultsの変更の監視を解除する
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
}

class ReservationEditController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var list: Array<Any>!
    let days = ["mon":"月曜日","tue":"火曜日","wed":"水曜日","thu":"木曜日","fri":"金曜日","sat":"土曜日","sun":"日曜日"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "超!A&G+ 予約リスト"
        self.view.backgroundColor = UIColor.white
        
        let back_button = UIBarButtonItem()
        back_button.image = UIImage.fontAwesomeIcon(name: .chevronLeft, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        back_button.target = self
        back_button.action = #selector(self.goback)
        self.navigationItem.leftBarButtonItem = back_button
        
        let table = UITableView(frame: self.view.bounds, style: .grouped)
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.dataSource = self
        table.delegate = self
        table.allowsMultipleSelection = false
        table.contentInset = UIEdgeInsets(top: -1.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (pending: [UNNotificationRequest]) in
            self.list = pending
         })
        self.view.addSubview(table)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.1;
        } else {
            return tableView.sectionHeaderHeight;
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = ["予約されている番組",""]
        return title[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value: Int
        if section == 0 {
            if list == nil || list.count == 0  {
                value = 1
            } else {
                value = list.count
            }
        } else {
            value = 1
        }
        return value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if indexPath.section == 0 {
            if list.count == 0 || list == nil {
                cell.textLabel?.text = "予約がありません"
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else {
                let data = list[indexPath.row] as! UNNotificationRequest
                let name = data.content.body.replacingOccurrences(of: "間もなく\"", with: "").replacingOccurrences(of: "\"が始まります", with: "")
                cell.textLabel?.text = name
                cell.textLabel?.numberOfLines = 0
                let dow = String(data.identifier.prefix(3))
                let time = data.identifier.replacingOccurrences(of: "\(dow)_", with: "")
                let frequency: String
                if data.trigger?.repeats == true {
                    frequency = "毎週"
                } else {
                    frequency = "1回のみ"
                }
                cell.detailTextLabel?.text = "\(frequency) \(days[dow]!) \(time)"
                cell.detailTextLabel?.numberOfLines = 0
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "予約を全消去する"
            cell.textLabel?.textColor = UIColor.red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func goback() {
        self.navigationController?.popViewController(animated: true)
    }
}
