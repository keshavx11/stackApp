//
//  ViewController.swift
//  stackApp
//
//  Created by Keshav Bansal on 31/05/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YSSegmentedControlDelegate {
    
    var segmented: YSSegmentedControl!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: UIViewController!
    weak var firstViewController: QuestionsViewController!
    weak var secondViewController: OfflineViewController!
    var viewIndex: Int = 0
    var panOnce: Int = 1
    var items = [String]()
    
    @IBOutlet weak var shadowView: UIView!
    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
    let barButtonColor = UIColor(red: 9/255.0, green: 80/255.0, blue: 208/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstViewController = self.storyboard?.instantiateViewController(withIdentifier: "QuestionView") as! QuestionsViewController
        firstViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.currentViewController = firstViewController
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.containerView)
        
        super.viewDidLoad()
        
        segmented = YSSegmentedControl(
            frame: CGRect(
                x: 0,
                y: 64,
                width: view.frame.size.width,
                height: 44),
            titles: [
                "QUESTIONS",
                "OFFLINE"
            ],
            action: {
                control, index in
        })
        segmented.delegate = self
        segmented.appearance.textColor = UIColor.black
        segmented.appearance.selectedTextColor = blueInstagramColor
        segmented.appearance.bottomLineColor = blueInstagramColor
        segmented.appearance.selectorColor = blueInstagramColor
        segmented.appearance.font = .boldSystemFont(ofSize: 14)
        
        view.addSubview(segmented)

    }
    
    func segmentedControlWillPressItemAtIndex(_ segmentedControl: YSSegmentedControl, index: Int) {
    }
    
    func segmentedControlDidPressedItemAtIndex(_ segmentedControl: YSSegmentedControl, index: Int) {
        if index == 0 {
            firstViewController = self.storyboard?.instantiateViewController(withIdentifier: "QuestionView") as! QuestionsViewController
            firstViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: firstViewController!)
            self.currentViewController = firstViewController
            
        } else {
            secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "OfflineView") as! OfflineViewController
            secondViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: secondViewController!)
            self.currentViewController = secondViewController
        }
        viewIndex = index
    }
    
    func cycleFromViewController(_ oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
        },
                       completion: { finished in
                        oldViewController.view.removeFromSuperview()
                        oldViewController.removeFromParentViewController()
                        newViewController.didMove(toParentViewController: self)
        })
    }
    
    func addSubview(_ subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                                 options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                 options: [], metrics: nil, views: viewBindingsDict))
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

