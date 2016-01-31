//
//  ThreadDetailViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import DSNestedAccordion

/*
- This is email 1
    - This is 1 child of email 1
    - This is 2 child of email 1
        - This is 1 child of email 1, 2
        - This is 2 child of email 1, 2
- This is email 2
    - This is 1 child of email 2
*/

struct TestEmail {
    let text: String
    let children: [TestEmail]
}

let email0 = TestEmail(text: "email 0", children: [email00, email01])
    let email00 = TestEmail(text: "email00", children: [])
    let email01 = TestEmail(text: "email01", children: [email010, email011])
        let email010 = TestEmail(text: "email010", children: [])
        let email011 = TestEmail(text: "email011", children: [])
let email1 = TestEmail(text: "email 1", children: [email10])
    let email10 = TestEmail(text: "email10", children: [])


let rootEmails = [email0, email1]

class AccordionDataSource: DSNestedAccordionHandler {
    override func noOfRowsInRootLevel() -> Int {
        return rootEmails.count
    }
    
    override func tableView(view: UITableView!, noOfChildRowsForCellAtPath path: DSCellPath!) -> Int {
        return emailForTreePath(rootEmails, path: path).children.count
    }
    
    private func emailForTreePath(list: [TestEmail], path: DSCellPath) -> TestEmail {
        let route = path.levelIndexes.map { $0.integerValue! }
        var email: TestEmail?
        var childList: [TestEmail] = list
        
        for i in 0..<route.count {
            if i == route.count - 1 {
                // Last
                email = childList[route[i]]
            } else {
                email = childList[route[i]]
                childList = email!.children
            }
        }
        
        return email!
    }
    
    override func tableView(view: UITableView!, cellForPath path: DSCellPath!) -> UITableViewCell! {
        let cell = view.dequeueReusableCellWithIdentifier("threadDetailCellIdentifier")!
        let email = emailForTreePath(rootEmails, path: path)
        cell.textLabel?.text = email.text
        return cell
    }
}

protocol ThreadDetailViewControllerDataSource: class {
    func threadDetailViewControllerEmailForIndexPath(threadDetailViewController: ThreadDetailViewController, indexPath: NSIndexPath) -> Email
    func threadDetailViewControllerNumberOfEmailsInSection(threadDetailViewController: ThreadDetailViewController, section: Int) -> Int
}

protocol ThreadDetailViewControllerDelegate: class {
    func threadDetailViewControllerDidNavigateBackwards(threadDetailViewController: ThreadDetailViewController)
}

class ThreadDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let reuseIdentifier = "threadDetailCellIdentifier"
    
    let accordionDataSource = AccordionDataSource()
    
    weak var dataSource: ThreadDetailViewControllerDataSource?
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
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = accordionDataSource
        tableView.delegate = accordionDataSource
    }
    
    override func viewDidLoad() {
        
    }
    
    func reload() {
        if tableView != nil {
            tableView.reloadData()
        }
    }
}
