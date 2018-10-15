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
    let rows = [["現在再生中の番組","番組表"],["今日更新予定の番組一覧","番組一覧"],["今日更新予定の番組一覧","番組一覧"],["設定"]]

    
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
    }
    
}
