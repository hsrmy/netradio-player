//
//  OnsenController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/4.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FontAwesome_swift
import SideMenu

class OnsenListController: ButtonBarPagerTabStripViewController {
    var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor.blue
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarHeight = 50.0
        settings.style.selectedBarBackgroundColor = UIColor.red
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        defaults.set("onsen", forKey: "last") // 音選を選局したことを保存
        defaults.synchronize()
        
        self.title = "インターネットラジオステーション＜音泉＞"
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
        
         let exit = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.onTapToolbar(sender:)))
        exit.tag = 0
        toolbar.items = [exit]
        self.view.addSubview(toolbar)
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
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let monVC = OnsenDayController(day: "mon")
        let tueVC = OnsenDayController(day: "tue")
        let wedVC = OnsenDayController(day: "wed")
        let thuVC = OnsenDayController(day: "thu")
        let friVC = OnsenDayController(day: "fri")
        let endVC = OnsenDayController(day: "sat")
        let allVC = OnsenAllController()
        
        let childViewControllers:[UIViewController] = [monVC,tueVC,wedVC,thuVC,friVC,endVC,allVC]
        
        return childViewControllers
    }
    
    @objc func showDrawer() {
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    // 向きが変わったらframeをセットしなおして再描画
    @objc func onOrientationChange(notification: NSNotification){
        let toolbar_y = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - UINavigationController().navigationBar.frame.size.height - settings.style.buttonBarHeight!
        toolbar.frame = CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!)
        
        self.toolbar.setNeedsDisplay()
        self.view.setNeedsLayout()
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
}
