//
//  FindUsersController.swift
//  Bell
//
//  Created by Derek Quach on 12/6/15.
//  Copyright © 2015 Derek Quach. All rights reserved.
//

import Foundation
import UIKit
import Parse

class FindUsersController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var users:[PFObject] = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        
        let query = PFQuery(className: "AlarmObject")
        query.whereKey("paired", equalTo: false)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            self.users = objects!
            print("Found", self.users.count, "users!")
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(tableView: UITableView,
        didSelectRowAtIndexPath
        indexPath: NSIndexPath) {
            
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return users.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            let cell =
            tableView.dequeueReusableCellWithIdentifier("userCell") as! UserCell
            
            cell.userNameLabel.text = (users[indexPath.row]["userName"] as! String)
            cell.dateLabel.text = (ClockController.convertDateToHM(users[indexPath.row]["dateTime"] as! NSDate))
            
            return cell
    }

}
