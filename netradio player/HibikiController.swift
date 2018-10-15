//
//  HibikiController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/15.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit

class HibikiController: UIViewController {
    
    override func viewDidLoad() {
        var navigationDrawer:NavigationDrawer!
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let defaults = UserDefaults.standard
        defaults.set("hibiki", forKey: "last") // 響を選局したことを保存
        defaults.synchronize()
        
        self.title = "響 - HiBiKi Radio Station"
        self.view.backgroundColor = UIColor.white
        
        let label = UILabel(frame: self.view.bounds)
        label.text = "響 - HiBiKi Radio Station"
        label.textAlignment = .center
        label.center = self.view.center
        self.view.addSubview(label)
        
        let drawer_button = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(self.showDrawer))
        self.navigationItem.leftBarButtonItem = drawer_button
        
        let options = NavigationDrawerOptions()
        options.navigationDrawerType = .LeftDrawer
        options.navigationDrawerOpenDirection = .AnyWhere
        options.navigationDrawerYPosition = 64
        
        let vc = DrawerMenuController()
        navigationDrawer = NavigationDrawer.sharedInstance
        navigationDrawer.setup(withOptions: options)
        navigationDrawer.setNavigationDrawerController(viewController: vc)
        
        let toolbar_y = UIScreen.main.bounds.height - (self.navigationController?.toolbar.frame.size.height)!
        let toolbar = UIToolbar(frame: CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!))
        toolbar.barStyle = .default
        self.view.addSubview(toolbar)
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

}
