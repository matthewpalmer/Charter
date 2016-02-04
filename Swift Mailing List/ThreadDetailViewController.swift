//
//  ThreadDetailViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import DSNestedAccordion

protocol ThreadDetailTableViewHandler: class, UITableViewDelegate, UITableViewDataSource {
    func noOfRowsInRootLevel() -> Int
    func tableView(view: UITableView!, noOfChildRowsForCellAtPath path: DSCellPath!) -> Int
    func tableView(view: UITableView!, cellForPath path: DSCellPath!) -> UITableViewCell!
}

protocol ThreadDetailViewControllerDelegate: class {
    func threadDetailViewControllerDidNavigateBackwards(threadDetailViewController: ThreadDetailViewController)
}

class ThreadDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    static let fullMessageCellIdentifier = "fullMessageCellId"
    
    weak var handler: ThreadDetailTableViewHandler?
    weak var delegate: ThreadDetailViewControllerDelegate?
    
    init() {
        super.init(nibName: "ThreadsViewController", bundle: NSBundle.mainBundle())
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
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        if let dataSource = tableView.dataSource as? DSNestedAccordionHandler {
            // Expand all cells
//            override func noOfRowsInRootLevel() -> Int {
//                return rootEmails.count
//            }
//            
//            override func tableView(view: UITableView!, noOfChildRowsForCellAtPath path: DSCellPath!) -> Int {
//                return emailForTreePath(rootEmails, path: path).children.count
//            }
            
            // For each cell at each level, call `toggleAtPath`.
            
            let root = (0..<dataSource.noOfRowsInRootLevel())
            for cell in root {
                let path = DSCellPath()
                
                path.levelIndexes.addObject(cell)
                dataSource.tableView(tableView, toggleAtPath: path)
                
                let children = (0..<dataSource.tableView(tableView, noOfChildRowsForCellAtPath: path))
                
                for child in children {
                    let newPath = DSCellPath()
                    newPath.levelIndexes = NSMutableArray(array: path.levelIndexes.arrayByAddingObject(child))
                    dataSource.tableView(tableView, toggleAtPath: newPath)
                }
            }
            
//            dataSource.tableView(tableView, toggleAtPath: <#T##DSCellPath!#>)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.registerNib(FullEmailMessageTableViewCell.nib(), forCellReuseIdentifier: ThreadDetailViewController.fullMessageCellIdentifier)
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = handler
        tableView.delegate = handler
    }
    
    override func viewDidLoad() {

    }
    
//    func reload() {
//        if tableView != nil {
//            tableView.reloadData()
//        }
//    }
}
