//
//  ThreadDetailViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class ThreadDetailViewController: UIViewController, UITableViewDelegate, FullEmailMessageTableViewCellDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private let dataSource: ThreadDetailDataSource
    
    init(dataSource: ThreadDetailDataSource) {
        self.dataSource = dataSource
        super.init(nibName: "ThreadDetailViewController", bundle: NSBundle.mainBundle())
    }
    
    override func viewDidLoad() {
        dataSource.registerTableView(tableView)
        dataSource.cellDelegate = self
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return dataSource.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath) ?? 0
    }
    
    func didChangeCellHeight(indexPath: NSIndexPath) {
        tableView.reloadData()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func presentPopover(view: UIView, sender: UIView) {
        let size: CGSize
        
        if UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight {
            size = CGSize(width: self.view.frame.width - 140, height: self.view.frame.height - 10)
        } else {
            size = CGSize(width: self.view.frame.width - 10, height: self.view.frame.height - 140)
        }
        
        let viewController = UIViewController()
        viewController.preferredContentSize = size
        viewController.view.backgroundColor = .whiteColor()
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        viewController.popoverPresentationController!.delegate = self
        viewController.popoverPresentationController!.sourceView = sender
        viewController.popoverPresentationController!.sourceRect = sender.frame
        viewController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0) // No arrow
        
        view.frame = CGRect(origin: CGPointZero, size: CGSize(width: size.width - 10, height: size.height - 10))
        viewController.view.addSubview(view)
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }
}
