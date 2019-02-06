//
//  OnsenTodayController.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/22.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit

class OnsenTodayController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var today_dow: Int!
    let dow = ["mon","tue","wed","thu","fri","sat"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "\"インターネットラジオステーション＜音泉＞\"の今日更新予定の番組一覧"
        self.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        let back_button = UIBarButtonItem()
        back_button.image = UIImage.fontAwesomeIcon(name: .chevronLeft, style: .solid, textColor: .blue, size: CGSize(width: 26, height: 26))
        back_button.target = self
        back_button.action = #selector(self.goback)
        self.navigationItem.leftBarButtonItem = back_button
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cal: NSCalendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let comp: NSDateComponents = cal.components([NSCalendar.Unit.weekday], from: NSDate() as Date) as NSDateComponents
        if comp.weekday == 1 {
            today_dow = 0
        } else {
            today_dow = comp.weekday-2
        }
        return (delegate.onseninfo[dow[today_dow]]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderWidth = 1.0
        
        let prog = delegate.onseninfo[dow[today_dow]]![indexPath.row]
        
        let thumbnail = UIImage(data: delegate.picarray!["onsen-\(prog[0])"] as! Data)
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
        //        let cell = collectionView.cellForItem(at: indexPath)
        let prog = delegate.onseninfo[dow[today_dow]]![indexPath.row]
        let thumbnail = delegate.picarray!["onsen-\(prog[0])"] as! Data
        let title = prog[1]
        let url = prog[4]
        let personality = prog[2]
        let caption = prog[3]
        let count = prog[6]
        
        let onsen = OnsenPlayerController(name: title, url: url, thumbnail: thumbnail, personality: personality, caption: caption, count: count)
        let navi = UINavigationController(rootViewController: onsen)
        self.present(navi, animated: true, completion: nil)
    }
    
    @objc func goback() {
        self.navigationController?.popViewController(animated: true)
    }
}
