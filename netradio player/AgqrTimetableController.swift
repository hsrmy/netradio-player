//
//  AgqrTimetableController.swift
//  netradio player
//
//  Created by hsrmy on 2018/11/23.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AgqrTimetableController: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor.blue
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarHeight = 50.0
        settings.style.selectedBarBackgroundColor = UIColor.red
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
        
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
            let monVC = DayTimetableController(day: "mon")
            let tueVC = DayTimetableController(day: "tue")
            let wedVC = DayTimetableController(day: "wed")
            let thuVC = DayTimetableController(day: "thu")
            let friVC = DayTimetableController(day: "fri")
            let satVC = DayTimetableController(day: "sat")
            let sunVC = DayTimetableController(day: "sun")
            
            let childViewControllers:[UIViewController] = [monVC,tueVC,wedVC,thuVC,friVC,satVC,sunVC]
            
            return childViewControllers
    }
}

class DayTimetableController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider,UIGestureRecognizerDelegate {
    var delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var day: String = ""
    var table: UITableView!
    let dow = ["mon":"月曜","tue":"火曜","wed":"水曜","thu":"木曜","fri":"金曜","sat":"土曜","sun":"日曜"]
    
    init(day: String) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        table = UITableView()
        table.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width/10)*8, height: (UIScreen.main.bounds.height/10)*7)
        table.dataSource = self
        table.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        longPressRecognizer.delegate = self
        table.addGestureRecognizer(longPressRecognizer)
        
        self.view.addSubview(table)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.agqrinfo[day]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let prog = delegate.agqrinfo[day]![indexPath.row]
        cell.textLabel?.text = prog[0]
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "\(prog[1])\n\(prog[2])〜\(prog[3])"
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: dow[day])
    }
    
    @objc func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: table)
        let indexPath = table.indexPathForRow(at: point)
        if indexPath == nil {
            
        } else if recognizer.state == UIGestureRecognizer.State.began  {
            let prog = delegate.agqrinfo[day]![(indexPath?.row)!]
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = prog[0]
            alert.message = "パーソナリティ:\(prog[1])\n\(dow[day]!) \(prog[2])〜\(prog[3])"
            alert.addAction(UIAlertAction(title: "予約リストに追加",style: .default,handler: {
                (action:UIAlertAction!) -> Void in print()
            }))
            alert.addAction(UIAlertAction(title: "OK",style: .cancel,handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
