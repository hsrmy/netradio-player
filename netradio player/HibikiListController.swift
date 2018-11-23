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

class HibikiListController: ButtonBarPagerTabStripViewController {
    var navigationDrawer:NavigationDrawer!
    
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
        super.viewWillAppear(true)
        
        NavigationDrawer.sharedInstance.initialize(forViewController: self)
    }
    
    @objc func showDrawer() {
        NavigationDrawer.sharedInstance.toggleNavigationDrawer(completionHandler: nil)
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
