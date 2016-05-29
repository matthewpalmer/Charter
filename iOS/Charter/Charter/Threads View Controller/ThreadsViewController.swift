//
//  ThreadsViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol ThreadsViewControllerDelegate: class {
    func threadsViewController(threadsViewController: ThreadsViewController, didSelectEmail email: Email)
    func threadsViewController(threadsViewController: ThreadsViewController, didSearchWithPhrase phrase: String, inMailingList mailingList: MailingListType)
}

class ThreadsViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private let dataSource: ThreadsViewControllerDataSource
    
    weak var delegate: ThreadsViewControllerDelegate?
    
    var searchEnabled = true
    var refreshEnabled = true
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    init(dataSource: ThreadsViewControllerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: "ThreadsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ThreadsViewController.didRequestRefresh(_:)), forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        self.dataSource.registerTableView(tableView)
        
        tableView.backgroundColor = UIColor(hue:0.67, saturation:0.02, brightness:0.96, alpha:1) // Group table background color
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        navigationItem.title = dataSource.title
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        updateSeparatorStyle()
        
        if searchEnabled {
            searchController.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
            tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.delegate = self
        }
        
        if refreshEnabled {
            tableView.addSubview(refreshControl)
        }
        
        // Check whether we are running UI tests before performing an automatic refresh.
        // If we refresh immediately the screenshots (which we take with Fastlane in doing the UI tests)
        // will be in an undefined state.
        if !NSUserDefaults.standardUserDefaults().boolForKey("FASTLANE_SNAPSHOT") {
            didRequestRefresh(self)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selected, animated: true)
        }
    }
    
    private func updateSeparatorStyle() {
        if dataSource.isEmpty {
            tableView.separatorStyle = .None
        } else {
            tableView.separatorStyle = .SingleLine
        }
    }
    
    func didRequestRefresh(sender: AnyObject) {
        dataSource.refreshDataFromNetwork { (success) -> Void in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.updateSeparatorStyle()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if dataSource.isEmpty {
            cell.userInteractionEnabled = false
        }
        
        if searchEnabled && cell is MessagePreviewTableViewCell {
            let messageCell = cell as! MessagePreviewTableViewCell
            messageCell.labelStackView.userInteractionEnabled = true
            messageCell.labelStackView.arrangedSubviews.forEach { labelView in
                let tap = UITapGestureRecognizer(target: self, action: #selector(ThreadsViewController.didTapLabelInCell(_:)))
                labelView.userInteractionEnabled = true
                labelView.addGestureRecognizer(tap)
                
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.threadsViewController(self, didSelectEmail: dataSource.emailAtIndexPath(indexPath))
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        delegate?.threadsViewController(self, didSearchWithPhrase: searchBar.text ?? "", inMailingList: dataSource.mailingList)
    }
    
    func didTapLabelInCell(sender: UIGestureRecognizer) {
        if let label = sender.view as? UILabel {
            let text = label.text?.lowercaseString ?? ""
            let regex = try! NSRegularExpression(pattern: "[a-z]+-[0-9]+", options: .CaseInsensitive)
            let searchText: String
            // If searching for an issue key (e.g. SE-0048), don't use square brackets
            if regex.matchesInString(text, options: [], range: NSMakeRange(0, text.characters.count)).count > 0 {
                searchText = text
            } else {
                searchText = "[\(text)]"
            }
            
            delegate?.threadsViewController(self, didSearchWithPhrase: searchText, inMailingList: dataSource.mailingList)
        }
    }
}
