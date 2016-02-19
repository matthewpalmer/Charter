//
//  ViewController2.swift
//  CollapsibleTextView
//
//  Created by Matthew Palmer on 6/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class RegionDataSource: CollapsibleTextViewDataSource {
    
}

class ViewController: UIViewController, CollapsibleTextViewDataSourceDelegate, RegionViewDelegate, UIPopoverPresentationControllerDelegate {
    let scrollView = UIScrollView()
    
    lazy var dataSource: RegionDataSource = {
        let file = NSBundle.mainBundle().URLForResource("Email", withExtension: nil)
        let data = NSData(contentsOfURL: file!)
        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
        let regions = [
            NSMakeRange(10, 50),
            NSMakeRange(100, 200),
            NSMakeRange(500, 75),
            NSMakeRange(900, 100)
        ]
        
        let dataSource = RegionDataSource(
            text: string as! String,
            initiallyCollapsedRegions: regions
        )
        
        return dataSource
    }()
    
    let regionView = RegionView()
    
    override func viewDidLoad() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let top = NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: scrollView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: scrollView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints([top, left, right, bottom])
        
        dataSource.delegate = self
        regionView.delegate = self
        regionView.dataSource = dataSource
        view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(regionView)
        
        setupRegionViewConstraints()
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize = regionView.frame.size
    }
    
    private func setupRegionViewConstraints() {
        let top = NSLayoutConstraint(item: regionView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: regionView, attribute: .Left, relatedBy: .Equal, toItem: scrollView, attribute: .Left, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: regionView, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0)
        
        scrollView.addConstraints([top, left, width])
    }
    
    func collapsibleTextViewDataSource(dataSource: CollapsibleTextViewDataSource, didChangeRegionAtIndex index: Int) {
        let newView = dataSource.regionView(regionView, viewForRegionAtIndex: index)
        regionView.replaceRegionAtIndex(index, withView: newView)
    }
    
    func regionView(regionView: RegionView, didFinishReplacingRegionAtIndex: Int) {
        scrollView.contentSize = regionView.frame.size
    }
    
    func collapsibleTextViewDataSourceNeedsPopoverViewControllerPresented(view: UIView, sender: UIView) {
        
    }
}
