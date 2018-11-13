//
//  SettingViewController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/23.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let section = ["アプリの設定","アプリの情報"]
    let row = [["前回終了時と同じ放送局を選局する","Wi-Fi接続時のみに再生する"],["Version","Build"]]
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let defaults = UserDefaults.standard
        cell.textLabel?.text = row[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
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
