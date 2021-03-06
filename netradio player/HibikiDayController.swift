//
//  OnsenMonController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/16.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HibikiDayController: UIViewController, IndicatorInfoProvider, UICollectionViewDataSource, UICollectionViewDelegate {
    var delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var day: String = ""
    var collectionView: UICollectionView!
    
    init(day: String) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: framesize), collectionViewLayout: layout)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange(notification:)),name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        switch day {
        case "mon":
            return IndicatorInfo(title: "月曜")
        case "tue":
            return IndicatorInfo(title: "火曜")
        case "wed":
            return IndicatorInfo(title: "水曜")
        case "thu":
            return IndicatorInfo(title: "木曜")
        case "fri":
            return IndicatorInfo(title: "金曜")
        case "sat":
            return IndicatorInfo(title: "土曜・日曜")
        default:
            return IndicatorInfo(title: "月曜")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (delegate.hibikiInfo[day]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderWidth = 1.0
        
        let prog = delegate.hibikiInfo[day]![indexPath.row]

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
        let prog =  delegate.hibikiInfo[day]![indexPath.row]
        let thumbnail = delegate.picarray!["hibiki-\(prog[0])"] as! Data
        
        let hibiki = HibikiPlayerController(id: prog[4], name: prog[1], personality: prog[2], thumbnail: thumbnail, caption: prog[3])
        let navi = UINavigationController(rootViewController: hibiki)
        self.present(navi, animated: true, completion: nil)
    }
    
    // 向きが変わったらframeをセットしなおして再描画
    @objc func onOrientationChange(notification: NSNotification){
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height + 50.0
        let framesize = UIScreen.main.bounds.size.height - uisize - UINavigationController().toolbar.frame.size.height
        
        collectionView.frame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: framesize)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.setNeedsDisplay()
        collectionView.reloadData()
    }
}
