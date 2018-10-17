//
//  HibikiEndController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/16.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HibikiEndController: UIViewController, IndicatorInfoProvider {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "土曜・日曜")
    }
    
}
