//
//  NavigationDrawer.swift
//
//  reference from https://github.com/nrlnishan/NavigationDrawer-Swift.git
//
//  Created by hsrmy on 2018/10/15.
//

import Foundation
import UIKit

@objc protocol NavigationDrawerDelegate {
    func navigationDrawerDidShow(didShow:Bool)
    func navigationDrawerDidHide(didHide:Bool)
}

enum NavigationDrawerType {
    case LeftDrawer
    case RightDrawer
}

enum NavigationDrawerOpenDirection {
    case AnyWhere
    case LeftEdge
    case RightEdge
}

class NavigationDrawer: NSObject {
    static let sharedInstance = NavigationDrawer()
    
    var delegate:NavigationDrawerDelegate?
    
    private var options:NavigationDrawerOptions!
    private var isDrawerShown = false
    private var navigationDrawerContainer = UIView()
    private var navigationDrawer = UIView()
    
    func setup(withOptions options:NavigationDrawerOptions) {
        self.options = options
    }
    
    private func initNavigationDrawer() {
        //setting up container for navigation drawer
        navigationDrawerContainer.frame = CGRect(x: 0, y: 0, width: options.getAnchorViewWidth(), height: options.getAnchorViewHeight())
        navigationDrawerContainer.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        //Tap gesture to hide drawer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapNavigation))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.delegate = self
        navigationDrawerContainer.addGestureRecognizer(tapGesture)
        
        //swipe gesture to hide and show drawer
        let drawerCloseGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeNavigation))
        
        if options.navigationDrawerType == NavigationDrawerType.LeftDrawer {
            let leftToRightSwiper = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeNavigation))
            leftToRightSwiper.direction = .right
            drawerCloseGesture.direction = .left
            options.anchorView!.addGestureRecognizer(leftToRightSwiper)
        } else {
            let rightToLeftSwiper = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeNavigation))
            rightToLeftSwiper.direction = .left
            drawerCloseGesture.direction = .right
            options.anchorView!.addGestureRecognizer(rightToLeftSwiper)
        }
        
        //setting up navigation drawer
        navigationDrawer.frame = CGRect(x: options.getNavigationDrawerXPosition(), y: options.navigationDrawerYPosition, width: options.navigationDrawerWidth,  height: options.navigationDrawerHeight)
        navigationDrawer.backgroundColor = options!.navigationDrawerBackgroundColor
        navigationDrawer.addGestureRecognizer(drawerCloseGesture)
        navigationDrawerContainer.addSubview(navigationDrawer)
        
    }
    
    func toggleNavigationDrawer(completionHandler: (()->Void)?) {
        if isDrawerShown == false {
            isDrawerShown = true
            self.options.anchorView!.addSubview(self.navigationDrawerContainer)
            self.options.anchorView!.bringSubviewToFront(self.navigationDrawerContainer)
            
            if options.navigationDrawerType == NavigationDrawerType.LeftDrawer {
                navigationDrawer.frame.origin.x = -options.navigationDrawerWidth
                
                UIView.animate(withDuration: 0.5, animations: {[unowned self]() -> Void in
                    
                    self.navigationDrawer.frame.origin.x += self.options.navigationDrawerWidth
                    self.navigationDrawerContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                    }, completion: {[unowned self](finished) -> Void in
                        if finished == true {
                            self.delegate?.navigationDrawerDidShow(didShow: true)
                            completionHandler?()
                        }
                })
            } else {
                navigationDrawer.frame.origin.x += options.navigationDrawerWidth
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    
                    self.navigationDrawer.frame.origin.x -= self.options.navigationDrawerWidth
                    //self.navigationDrawerContainer.alpha = 0.4
                    self.navigationDrawerContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                }, completion: { (finished) -> Void in
                    self.delegate?.navigationDrawerDidShow(didShow: true)
                    completionHandler?()
                })
            }
        } else {
            isDrawerShown = false
            if options.navigationDrawerType == NavigationDrawerType.LeftDrawer
            {
                UIView.animate(withDuration: 0.5, animations: {[unowned self]() -> Void in
                    
                    self.navigationDrawer.frame.origin.x -= self.options.navigationDrawerWidth
                    self.navigationDrawerContainer.backgroundColor = UIColor.black.withAlphaComponent(0)
                    }, completion: {[unowned self](finished) -> Void in
                        if finished
                        {
                            self.navigationDrawerContainer.removeFromSuperview()
                            self.delegate?.navigationDrawerDidHide(didHide: true)
                            completionHandler?()
                        }
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {[unowned self]() -> Void in
                    
                    self.navigationDrawer.frame.origin.x += self.options.navigationDrawerWidth
                    self.navigationDrawerContainer.backgroundColor = UIColor.black.withAlphaComponent(0)
                    }, completion: {[unowned self](finished) -> Void in
                        if finished
                        {
                            self.navigationDrawerContainer.removeFromSuperview()
                            self.navigationDrawer.frame.origin.x = self.options.navigationDrawerXPosition
                            self.delegate?.navigationDrawerDidHide(didHide: true)
                            completionHandler?()
                        }
                })
            }
        }
    }
    
    @objc func handleTapNavigation(sender:UITapGestureRecognizer) {
        toggleNavigationDrawer(completionHandler: nil)
    }
    
    @objc func handleSwipeNavigation(sender:UISwipeGestureRecognizer) {
        let location = sender.location(in: options.anchorView).x
        
        if isDrawerShown == false {
            //For Opening
            if options.navigationDrawerOpenDirection == NavigationDrawerOpenDirection.AnyWhere {
                toggleNavigationDrawer(completionHandler: nil)
            } else {
                if sender.direction == UISwipeGestureRecognizer.Direction.right {
                    if location <= options.navigationDrawerEdgeSwipeDistance {
                        toggleNavigationDrawer(completionHandler: nil)
                    }
                } else if sender.direction == UISwipeGestureRecognizer.Direction.left {
                    if location >= options.getAnchorViewWidth() - options.navigationDrawerEdgeSwipeDistance {
                        toggleNavigationDrawer(completionHandler: nil)
                    }
                }
            }
        } else {
            //For Closing
            if options.navigationDrawerType == NavigationDrawerType.LeftDrawer {
                if sender.direction == UISwipeGestureRecognizer.Direction.left {
                    toggleNavigationDrawer(completionHandler: nil)
                }
            } else {
                if sender.direction == UISwipeGestureRecognizer.Direction.right {
                    toggleNavigationDrawer(completionHandler: nil)
                }
            }
        }
    }
    
    func setNavigationDrawerController(viewController:UIViewController) {
        self.options.drawerController = viewController
        viewController.view.frame = navigationDrawer.bounds
        self.navigationDrawer.addSubview(viewController.view)
    }

    func initialize(forViewController viewController:UIViewController) {
        options.anchorView = viewController.view
        options.initDefaults()
        viewController.addChild(options.drawerController!)
        initNavigationDrawer()
    }
}

class NavigationDrawerOptions {
    var anchorView:UIView?
    private var anchorViewHeight:CGFloat!
    private var anchorViewWidth:CGFloat!
    
    var navigationDrawerWidth:CGFloat!
    var navigationDrawerHeight:CGFloat!
    var navigationDrawerXPosition:CGFloat!
    var navigationDrawerYPosition:CGFloat!
    var navigationDrawerBackgroundColor = UIColor.clear
    var navigationDrawerType = NavigationDrawerType.LeftDrawer
    var navigationDrawerOpenDirection = NavigationDrawerOpenDirection.AnyWhere
    var navigationDrawerEdgeSwipeDistance:CGFloat = 20.0
    
    var drawerController:UIViewController?
    
    init() {
        navigationDrawerXPosition = 0
        navigationDrawerYPosition = 0
    }
    
    func initDefaults() {
        anchorViewHeight = self.anchorView!.frame.size.height
        anchorViewWidth = self.anchorView!.frame.size.width
    
        let uisize: CGFloat = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.size.height
        let framesize = UIScreen.main.bounds.size.height - uisize
        
        if navigationDrawerWidth == nil {
            navigationDrawerWidth = self.anchorView!.frame.size.width/2
        }
        if navigationDrawerHeight == nil {
            navigationDrawerHeight = framesize
        }
    }
    
    func getNavigationDrawerXPosition() -> CGFloat{
        if navigationDrawerType == .LeftDrawer {
            navigationDrawerXPosition = 0
        } else {
            navigationDrawerXPosition = anchorViewWidth - navigationDrawerWidth
        }
        return navigationDrawerXPosition
    }
    
    func getAnchorViewWidth() -> CGFloat {
        return self.anchorViewWidth
    }
    
    func getAnchorViewHeight() -> CGFloat {
        return self.anchorViewHeight
    }
    
}

extension NavigationDrawer: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: options.anchorView)
        if navigationDrawer.frame.contains(location) {
            return false
        }
        return true
    }
}

