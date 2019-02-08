//
//  HibikiAllController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/17.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HibikiAllController: UIViewController, IndicatorInfoProvider, UICollectionViewDataSource, UICollectionViewDelegate {
    var delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dow = ["mon","tue","wed","thu","fri","sat"]
    
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
        let framesize = UIScreen.main.bounds.size.height - uisize - UINavigationController().toolbar.frame.size.height
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: framesize), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.view.addSubview(collectionView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "全て")
    }
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegate.hibikiInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (delegate.hibikiInfo[dow[section]]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderWidth = 1.0
        
        let prog = delegate.hibikiInfo[dow[indexPath.section]]![indexPath.row]
        
        let thumbnail = UIImage(data: delegate.picarray!["hibiki-\(prog[0])"] as! Data)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height/2))
        imageView.image = thumbnail
        cell.contentView.addSubview(imageView)

        let label = UILabel(frame: CGRect(x: 0, y: cell.contentView.frame.height/2, width: cell.contentView.frame.width, height: cell.contentView.frame.height/2))
        label.textAlignment = .center
        label.text = "\(prog[1])\n\n\(prog[2])"
        label.numberOfLines = 0
        cell.contentView.addSubview(label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let prog =  delegate.hibikiInfo[dow[indexPath.section]]![indexPath.row]
        let thumbnail = delegate.picarray!["hibiki-\(prog[0])"] as! Data
        
        let hibiki = HibikiPlayerController(id: prog[4], name: prog[1], personality:prog[2], thumbnail: thumbnail, caption: prog[3])
        let navi = UINavigationController(rootViewController: hibiki)
        self.present(navi, animated: true, completion: nil)
    }
}
