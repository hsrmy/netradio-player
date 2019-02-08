//
//  HibikiController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/15.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import FontAwesome_swift
import XLPagerTabStrip
import SideMenu

class HibikiListController: ButtonBarPagerTabStripViewController {
    var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor.blue
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarHeight = 50.0
        settings.style.selectedBarBackgroundColor = UIColor.red
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let defaults = UserDefaults.standard
        defaults.set("hibiki", forKey: "last") // 響を選局したことを保存
        defaults.synchronize()
        
        self.title = "響 - HiBiKi Radio Station"
        self.view.backgroundColor = UIColor.white
        // XLPagerTabStripをナビゲーションバーにめり込ませない
        navigationController?.navigationBar.isTranslucent = false
        
        let drawer_button = UIBarButtonItem()
        drawer_button.image = UIImage.fontAwesomeIcon(name: .bars, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        drawer_button.target = self
        drawer_button.action = #selector(self.showDrawer)
        self.navigationItem.leftBarButtonItem = drawer_button
        
        let toolbar_y = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - UINavigationController().navigationBar.frame.size.height - settings.style.buttonBarHeight!
        toolbar = UIToolbar(frame: CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!))
        toolbar.barStyle = .default
        
        let table = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.onTapToolbar(sender:)))
        table.tag = 0
        toolbar.items = [table]
        self.view.addSubview(toolbar)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let monVC = HibikiDayController(day: "mon")
        let tueVC = HibikiDayController(day: "tue")
        let wedVC = HibikiDayController(day: "wed")
        let thuVC = HibikiDayController(day: "thu")
        let friVC = HibikiDayController(day: "fri")
        let endVC = HibikiDayController(day: "sat")
        let allVC = HibikiAllController()
        
        let childViewControllers:[UIViewController] = [monVC,tueVC,wedVC,thuVC,friVC,endVC,allVC]
        
        return childViewControllers
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange(notification:)),name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func showDrawer() {
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }

    @objc func onTapToolbar(sender: UIButton){
        switch(sender.tag){
        // 終了ボタン
        case 0:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "確認"
            alert.message = "アプリを終了しますか?"
            alert.addAction(UIAlertAction(title: "はい",style: .destructive,handler: {
                (action:UIAlertAction!) -> Void in exit(0)
            }))
            alert.addAction(UIAlertAction(title: "キャンセル",style: .cancel,handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            print("error")
        }
    }
 
    @objc func onOrientationChange(notification: NSNotification){
         let toolbar_y = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - UINavigationController().navigationBar.frame.size.height - settings.style.buttonBarHeight!
        toolbar.frame = CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!)
        
        self.toolbar.setNeedsDisplay()
        self.view.setNeedsLayout()
    }
}
