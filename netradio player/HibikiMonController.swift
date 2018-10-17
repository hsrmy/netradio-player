//
//  OnsenMonController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/16.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HibikiMonController: UIViewController, IndicatorInfoProvider, UICollectionViewDataSource,UICollectionViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
        let layout = UICollectionViewFlowLayout()
        if UIDevice.current.userInterfaceIdiom == .pad { // iPadの場合
            let size: CGFloat = (UIScreen.main.bounds.width - (25*3))/3
            layout.itemSize = CGSize(width: size, height: size)
            layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 20)
        } else if UIDevice.current.userInterfaceIdiom == .phone { // iPhoneの場合
            let size: CGFloat = (UIScreen.main.bounds.width - (25*3))/2
            layout.itemSize = CGSize(width: size, height: size)
            layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        }
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
        
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height + 50.0
        let framesize = UIScreen.main.bounds.size.height - uisize - (navigationController?.toolbar.frame.size.height)!
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: framesize), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.view.addSubview(collectionView)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "月曜")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
//        cell.backgroundColor = .red
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderWidth = 1.0
        
        let label = UILabel()
        label.center = cell.contentView.center
        label.text = indexPath.row.description
        label.sizeToFit()
        cell.contentView.addSubview(label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
    }
}
