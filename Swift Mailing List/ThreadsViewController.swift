//
//  ThreadsViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import ReSwift

protocol ThreadsViewControllerDelegate: class {
    func threadsViewControllerDidSelectRowAtIndexPath(indexPath: NSIndexPath)
    func threadsViewControllerRequestsReloadedData()
}

class ThreadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    typealias StoreSubscriberStateType = AppState
    
    private let reuseIdentifier = "threadsCellReuseIdentifier"
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: ThreadsViewControllerDelegate?
    
    init() {
        super.init(nibName: "ThreadsViewController", bundle: NSBundle.mainBundle())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        delegate?.threadsViewControllerRequestsReloadedData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        delegate?.threadsViewControllerRequestsReloadedData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = mainStore.state.rootEmailList[indexPath.row].headers.subject
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.threadsViewControllerDidSelectRowAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainStore.state.rootEmailList.count
    }
    
    func relod() {
        tableView.reloadData()
    }
}
