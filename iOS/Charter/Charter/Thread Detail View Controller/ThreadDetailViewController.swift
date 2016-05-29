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
    
    private var navigationBar: UINavigationBar? { return navigationController?.navigationBar }
    
    private lazy var nextMessageButton: UIBarButtonItem = { UIBarButtonItem(image: UIImage(named: "UIButtonBarArrowDown"), style: .Plain, target: self, action: #selector(self.scrollToNextMessage)) }()
    private lazy var previousMessageButton: UIBarButtonItem = { UIBarButtonItem(image: UIImage(named: "UIButtonBarArrowUp"), style: .Plain, target: self, action: #selector(self.scrollToPreviousMessage)) }()
    
    init(dataSource: ThreadDetailDataSource) {
        self.dataSource = dataSource
        super.init(nibName: "ThreadDetailViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        setupNavigationButtons()
    }
    
    func setupNavigationButtons() {
        navigationItem.rightBarButtonItems = [nextMessageButton, previousMessageButton]
        updateNavigationButtons()
    }
    
    func updateNavigationButtons() {
        guard let navigationBar = navigationBar else { return }
        
        previousMessageButton.enabled = tableView.contentOffset.y > 0
        
        let lastRowIndexPath = NSIndexPath(forRow: lastRowIndex, inSection: 0)
        let navBarOffset = navigationBar.frame.size.height + navigationBar.frame.origin.y
        nextMessageButton.enabled = tableView.contentOffset.y < tableView.rectForRowAtIndexPath(lastRowIndexPath).origin.y - navBarOffset - 1
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavigationButtons()
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

// Logic for navigation buttons (previous/next arrows)
extension ThreadDetailViewController {
    private var firstVisibleRowIndex: Int? {
        guard let navigationBar = navigationBar else { return nil }
        let convertedNavBarFrame = tableView.convertRect(navigationBar.bounds, fromView: navigationBar)
        let samplingY = convertedNavBarFrame.origin.y + convertedNavBarFrame.size.height + 1
        return tableView.indexPathForRowAtPoint(CGPoint(x: 0, y: samplingY))?.row
    }
    
    private var lastRowIndex: Int {
        return dataSource.tableView(tableView, numberOfRowsInSection: 0) - 1
    }
    
    func scrollToPreviousMessage() {
        guard let currentIndex = firstVisibleRowIndex else { return }
        scrollToRowAtIndex(requestedIndex: currentIndex - 1)
    }
    
    func scrollToNextMessage() {
        guard let currentIndex = firstVisibleRowIndex else { return }
        scrollToRowAtIndex(requestedIndex: currentIndex + 1)
    }
    
    private func scrollToRowAtIndex(requestedIndex index: Int) {
        let indexPath = NSIndexPath(forRow: clamp(index, min: 0, max: lastRowIndex), inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    private func clamp<T : Comparable>(value: T, min: T, max: T) -> T {
        if (value < min) { return min }
        if (value > max) { return max }
        return value
    }
}
