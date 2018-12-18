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
                self.navigationController?.pushViewController(agqr, animated: true)
            } else { // A&Gの番組表のとき
                
            }
        } else if indexPath.section == 1 { // 音泉
            if indexPath.row == 0 { // 「今日更新予定の番組一覧」の時
                let onsen = OnsenTodayController()
                self.navigationController?.pushViewController(onsen, animated: true)
            } else { // 「番組一覧」の時
                let onsen = OnsenListController()
                self.navigationController?.pushViewController(onsen, animated: true)
            }
        } else if indexPath.section == 2 { // 響
            if indexPath.row == 0 { // 「今日更新予定の番組一覧」の時
                let hibiki = HibikiTodayController()
                self.navigationController?.pushViewController(hibiki, animated: true)
            } else {
                let hibiki = HibikiListController()
                self.navigationController?.pushViewController(hibiki, animated: true)
            }
        } else { // 設定
            let setting = SettingViewController()
            self.navigationController?.pushViewController(setting, animated: true)
        }
    }
    
}
