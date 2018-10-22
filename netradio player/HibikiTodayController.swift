//
//  HibikiTodayController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/22.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit

class HibikiTodayController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let list = UserDefaults.standard.object(forKey: "hibikilist") as! [String:Array<String>]
    let rawinfo = UserDefaults.standard.object(forKey: "hibikiInfo") as! [String:Array<Any>]
    var info: [String:Array<Any>]!
    var today_dow: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "\"響 - HiBiKi Radio Station\"の今日更新予定の番組一覧"
        self.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
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
        
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height + 10.0
        let framesize = UIScreen.main.bounds.size.height - uisize - UINavigationController().toolbar.frame.size.height
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: framesize), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let toolbar_y = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - UINavigationController().navigationBar.frame.size.height
        let toolbar = UIToolbar(frame: CGRect(x: 0, y:
            toolbar_y, width: self.view.bounds.size.width, height: (self.navigationController?.toolbar.frame.size.height)!))
        toolbar.barStyle = .default
        
        self.view.addSubview(collectionView)
        self.view.addSubview(toolbar)
        
        self.info = [String:Array<Any>]()
        for (key,value) in rawinfo {
            if value.count > 0 {
                if info[key] == nil {
                    info[key] = []
                }
                info[key] = [value[0] as! String, value[1] as! String, value[2] as! String, value[3] as! String, value[4] as! Data]
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cal: NSCalendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let comp: NSDateComponents = cal.components([NSCalendar.Unit.weekday], from: NSDate() as Date) as NSDateComponents
        if comp.weekday == 1 {
            today_dow = "0"
        } else {
            today_dow = (comp.weekday-1).description
        }
        return list[today_dow]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
                
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderWidth = 1.0
        
        let prog = list[today_dow]?[indexPath.row]
        
        let thumbnail = UIImage(data: info[prog!]?[4] as! Data)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height/2))
        imageView.image = thumbnail
        cell.contentView.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: 0, y: cell.contentView.frame.height/2, width: cell.contentView.frame.width, height: cell.contentView.frame.height/2))
        label.textAlignment = .center
        label.text = "\(info[prog!]?[0] as! String)\n\n\(info[prog!]?[1] as! String)"
        label.numberOfLines = 0
        cell.contentView.addSubview(label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        let cell = collectionView.cellForItem(at: indexPath)
        let prog = list[(indexPath.section+1).description]?[indexPath.row]
        let id = info[prog!]?[3] as! String
        let thumbnail = info[prog!]?[4] as! Data
        
        let hibiki = HibikiPlayerController(id: id,thumbnail: thumbnail)
        let navi = UINavigationController(rootViewController: hibiki)
        self.present(navi, animated: true, completion: nil)
    }
}
