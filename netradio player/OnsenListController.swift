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

class OnsenListController: ButtonBarPagerTabStripViewController {
    var navigationDrawer: NavigationDrawer!
    
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
    
        // XLPagerTabStripをｓナビゲーションバーにめり込ませない
        navigationController?.navigationBar.isTranslucent = false
        
        let drawer_button = UIBarButtonItem()
        drawer_button.image = UIImage.fontAwesomeIcon(name: .bars, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        drawer_button.target = self
        drawer_button.action = #selector(self.showDrawer)
        self.navigationItem.leftBarButtonItem = drawer_button
        
        let options = NavigationDrawerOptions()
        options.navigationDrawerType = .LeftDrawer
        options.navigationDrawerOpenDirection = .AnyWhere
        options.navigationDrawerYPosition = 64
        
        let vc = DrawerMenuController()
        navigationDrawer = NavigationDrawer.sharedInstance
        navigationDrawer.setup(withOptions: options)
        navigationDrawer.setNavigationDrawerController(viewController: vc)
        
        let toolbar_y = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - UINavigationController().navigationBar.frame.size.height - settings.style.buttonBarHeight!
        let toolbar = UIToolbar(frame: CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!))
        toolbar.barStyle = .default
        
        let table = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.onTapToolbar(sender:)))
        table.tag = 2
        toolbar.items = [table]
        self.view.addSubview(toolbar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange(notification:)),name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        NavigationDrawer.sharedInstance.initialize(forViewController: self)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let monVC = OnsenDayController(day: "mon")
        let tueVC = OnsenDayController(day: "tue")
        let wedVC = OnsenDayController(day: "wed")
        let thuVC = OnsenDayController(day: "wed")
        let friVC = OnsenDayController(day: "fri")
        let endVC = OnsenDayController(day: "sat")
        let allVC = OnsenAllController()
        
        let childViewControllers:[UIViewController] = [monVC,tueVC,wedVC,thuVC,friVC,endVC,allVC]
        
        return childViewControllers
    }
    
    @objc func showDrawer() {
        NavigationDrawer.sharedInstance.toggleNavigationDrawer(completionHandler: nil)
    }
    
    // 向きが変わったらframeをセットしなおして再描画
    @objc func onOrientationChange(notification: NSNotification){
        // UI(ステータスバーとナビゲーションバー)の高さ
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height
        let framesize = UIScreen.main.bounds.size.height - uisize // フレームの大きさの高さ
        // フレームの大きさをビューの大きさに
//        progTable.frame = CGRect(x: 0, y: uisize, width: UIScreen.main.bounds.size.width, height: framesize)
//        
//        progTable.setNeedsLayout()
    }
    
    @objc func onTapToolbar(sender: UIButton){
        switch(sender.tag){
        //更新ボタン
        case 2:
            print("tapped")
        default:
            print("error")
        }
    }
}
