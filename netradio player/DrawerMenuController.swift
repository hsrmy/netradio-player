//
//  DrawerMenuViewController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/15.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit

class DrawerMenuController: UITableViewController {
    let sections = ["超!A&G+", "音泉", "響", " "]
    let rows = [["今すぐ超!A&G+を聞く","番組表"],["今日更新予定の番組一覧","番組一覧"],["今日更新予定の番組一覧","番組一覧"],["設定"]]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.sectionHeaderHeight = 100
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = rows[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 { // A&G
            if indexPath.row == 0 { // 「今すぐ超!A&G+を聞く」の時
                let agqr = AgqrController()
                let navi = UINavigationController(rootViewController: agqr)
                NavigationDrawer.sharedInstance.toggleNavigationDrawer(completionHandler: nil)
                self.present(navi, animated: true, completion: nil)
            } else { // A&Gの番組表のとき
                
            }
        } else if indexPath.section == 1 { // 音泉
            if indexPath.row == 0 { // 「今日更新予定の番組一覧」の時
                let onsen = OnsenTodayController()
                let navi = UINavigationController(rootViewController: onsen)
                NavigationDrawer.sharedInstance.toggleNavigationDrawer(completionHandler: nil)
                self.present(navi, animated: true, completion: nil)
            } else { // 「番組一覧」の時
                let onsen = OnsenListController()
                let navi = UINavigationController(rootViewController: onsen)
                NavigationDrawer.sharedInstance.toggleNavigationDrawer(completionHandler: nil)
                DispatchQueue.main.async {
                    self.view.makeToast("\"インターネットラジオステーション＜音泉＞\"を選局します\nしばらくお待ち下さい", duration: 3)
                }
                self.present(navi, animated: true, completion: nil)
            }
        } else if indexPath.section == 2 { // 響
            if indexPath.row == 0 { // 「今日更新予定の番組一覧」の時
                let hibiki = HibikiTodayController()
                let navi = UINavigationController(rootViewController: hibiki)
                NavigationDrawer.sharedInstance.toggleNavigationDrawer(completionHandler: nil)
                self.present(navi, animated: true, completion: nil)
            } else {
                let hibiki = HibikiListController()
                let navi = UINavigationController(rootViewController: hibiki)
                NavigationDrawer.sharedInstance.toggleNavigationDrawer(completionHandler: nil)
                DispatchQueue.main.async {
                    self.view.makeToast("\"響 - HiBiKi Radio Station\"を選局します\nしばらくお待ち下さい", duration: 3)
                }
                self.present(navi, animated: true, completion: nil)
            }
        } else { // 設定
            let setting = SettingViewController()
            let navi = UINavigationController(rootViewController: setting)
            NavigationDrawer.sharedInstance.toggleNavigationDrawer(completionHandler: nil)
            self.present(navi, animated: true, completion: nil)
        }
    }
    
}
