//
//  ThreadDetailViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol ThreadDetailDataSource: class, UITableViewDataSource {
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int
}

protocol ThreadDetailViewControllerDelegate: class {
    func threadDetailViewControllerDidNavigateBackwards(threadDetailViewController: ThreadDetailViewController)
}

class ThreadDetailViewController: UIViewController, UITableViewDelegate, FullEmailMessageTableViewCellDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    static let fullMessageCellIdentifier = "fullMessageCellId"
    
    weak var dataSource: ThreadDetailDataSource? {
        didSet {
            if tableView != nil {
                tableView.dataSource = dataSource
            }
        }
    }
    weak var delegate: ThreadDetailViewControllerDelegate?
    
    init() {
        super.init(nibName: "ThreadDetailViewController", bundle: NSBundle.mainBundle())
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            // Pressed 'Back' from this screen. Need to update our route history.
            delegate?.threadDetailViewControllerDidNavigateBackwards(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(animated: Bool) {
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.registerNib(FullEmailMessageTableViewCell.nib(), forCellReuseIdentifier: ThreadDetailViewController.fullMessageCellIdentifier)
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return dataSource?.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath) ?? 0
    }
    
    func didChangeCellHeight(indexPath: NSIndexPath) {
        tableView.reloadData()
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func presentPopover(view: UIView, sender: UIView) {
        let size = CGSize(width: self.view.frame.width - 10, height: self.view.frame.height - 140)
        
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
