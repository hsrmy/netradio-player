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
    let row = [["前回終了時と同じ放送局を選局する","Wi-Fi接続時のみに再生する","音泉番組情報保持期間","響番組情報保持期間"],["Version","Build"]]
    let defaults = UserDefaults.standard
    var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "設定"
        self.view.backgroundColor = UIColor.white
        
        setdefaultValue()
        
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
            if indexPath.row == 0 || indexPath.row == 1 {
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
            } else if indexPath.row == 2 {
                cell.detailTextLabel?.text = "\(defaults.integer(forKey: "onsen_time"))日"
            } else if indexPath.row == 3 {
                cell.detailTextLabel?.text = "\(defaults.integer(forKey: "hibiki_time"))日"
            }
        } else if indexPath.section == 1 {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let bundlesPath = Bundle.main.path(forResource: "Settings.bundle", ofType: nil) {
                if let plistPath = Bundle.path(forResource: "Root", ofType: "plist", inDirectory: bundlesPath) {
                    let plist = NSDictionary(contentsOfFile: plistPath)
                    let array = plist?.object(forKey: "PreferenceSpecifiers") as! NSArray
                    if indexPath.row == 0 {
                        cell.detailTextLabel?.text = (array[6] as AnyObject).value(forKey: "DefaultValue") as? String
                    } else if indexPath.row == 1 {
                        cell.detailTextLabel?.text = (array[7] as AnyObject).value(forKey: "DefaultValue") as? String
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 2 || indexPath.row == 3 {
                let edit = SettingEditController(mode: indexPath.row)
                let navi = UINavigationController(rootViewController: edit)
                self.present(navi, animated: true, completion: nil)
            }
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
    
    func setdefaultValue() {
        if let bundlesPath = Bundle.main.path(forResource: "Settings.bundle", ofType: nil) {
            if let plistPath = Bundle.path(forResource: "Root", ofType: "plist", inDirectory: bundlesPath) {
                let plist = NSDictionary(contentsOfFile: plistPath)
                let array = plist?.object(forKey: "PreferenceSpecifiers") as! NSArray
                if defaults.object(forKey: "onsen_time") == nil{
                    let value = (array[3] as AnyObject).value(forKey: "DefaultValue") as? Int
                    defaults.set(value, forKey: "onsen_time")
                }
                if defaults.object(forKey: "hibiki_time") == nil {
                    let value = (array[4] as AnyObject).value(forKey: "DefaultValue") as? Int
                    defaults.set(value, forKey: "hibiki_time")
                }
            }
        }
    }
    
}

class SettingEditController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let defaults = UserDefaults.standard
    let text = ["1日","3日","5日","7日"]
    var mode: Int!
    var select = 1
    
    init(mode: Int) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "選択してください"
        
        let table = UITableView(frame: self.view.bounds, style: .grouped)
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.dataSource = self
        table.delegate = self
        
        let back_button = UIBarButtonItem()
        back_button.image = UIImage.fontAwesomeIcon(name: .chevronLeft, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        back_button.target = self
        back_button.action = #selector(self.goback)
        self.navigationItem.leftBarButtonItem = back_button
        
        if mode == 2 {
            let value = defaults.integer(forKey: "onsen_time")
            switch(value){
            case 1:
                select = 0
            case 3:
                select = 1
            case 5:
                select = 2
            case 7:
                select = 3
            default:
                select = 1
            }
        } else if mode == 3 {
            let value = defaults.integer(forKey: "hibiki_time")
            switch(value){
            case 1:
                select = 0
            case 3:
                select = 1
            case 5:
                select = 2
            case 7:
                select = 3
            default:
                select = 1
            }
        }
        
        self.view.addSubview(table)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = text[indexPath.row]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if indexPath.row == select {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        if cell?.accessoryType == UITableViewCell.AccessoryType.none {
            cell?.accessoryType = .checkmark
            select = indexPath.row
        } else {
            cell?.accessoryType = .none
        }
        tableView.reloadData()
    }
    

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
    }
    
    @objc func goback() {
        if mode == 2 {
            switch(select){
            case 0:
                defaults.set(1, forKey: "onsen_time")
            case 1:
                defaults.set(3, forKey: "onsen_time")
            case 2:
                defaults.set(5, forKey: "onsen_time")
            case 3:
                defaults.set(7, forKey: "onsen_time")
            default:
                defaults.set(3, forKey: "onsen_time")
            }
        } else if mode == 3 {
            switch(select){
            case 0:
                defaults.set(1, forKey: "hibiki_time")
            case 1:
                defaults.set(3, forKey: "hibiki_time")
            case 2:
                defaults.set(5, forKey: "hibiki_time")
            case 3:
                defaults.set(7, forKey: "hibiki_time")
            default:
                defaults.set(3, forKey: "hibiki_time")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
