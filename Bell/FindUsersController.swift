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

        let defaults = NSUserDefaults.standardUserDefaults()
        
        let query = PFQuery(className: "AlarmObject")
        query.whereKey("active", equalTo: true)
        query.whereKey("paired", equalTo: false)    
        if let myId = defaults.stringForKey("myId") {
            query.whereKey("objectId", notEqualTo: myId)
        }
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
        let partnerCandidate = users[indexPath.row]

        let candidateName = partnerCandidate["userName"] as! String
        let dateTime = ClockController.convertDateToHM(partnerCandidate["dateTime"] as! NSDate)
        
        // Kick off alert to confirm selecting this alarm to pair with.
        let alert = UIAlertController(title: "Confirm Pairing", message: "Are you sure you want to wake up with " + candidateName + " at " + dateTime, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Accepted")
            
                self.setupAlarm(partnerCandidate)
                self.tableView.reloadData()
            }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Refused")
            }))
            
            
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func setupAlarm(alarmObject: PFObject) {
        let defaults = NSUserDefaults.standardUserDefaults()

        // Set things up locally
        let partnerName = alarmObject["userName"] as! String
        let alarmTime = alarmObject["dateTime"] as! NSDate 
        let partnerId = alarmObject.objectId! as String
        
        defaults.setObject(partnerName, forKey: "partnerName")
        defaults.setObject(alarmTime, forKey: "alarmTime") // You adopt your partners time
        defaults.setObject(partnerId, forKey: "partnerId")

        // Set you and your partners alarms as paired.
        
        let myId = defaults.stringForKey("myId") 
        print("1", myId)
        let myQuery = PFQuery(className: "AlarmObject")
        myQuery.getObjectInBackgroundWithId(myId!) {
        (alarm: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                alarm!["active"] = true
                alarm!["paired"] = true
                alarm!["partnerId"] = partnerId
                alarm!.setObject(alarmTime, forKey: "dateTime")
                alarm!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    defaults.setObject(true, forKey: "isAlarmActive")
                    ClockController.queueUpLocalNotifications(alarmTime)
                    print("Object has been saved.")
                }
                print("Updated self")
            } else {
                NSLog("%@", error!)
            }
        }
        
        
        print("2", partnerId)
        let partnerQuery = PFQuery(className: "AlarmObject")
        partnerQuery.getObjectInBackgroundWithId(partnerId) {
            (alarm: PFObject?, error: NSError?) -> Void in
            if (error == nil) {	
                alarm!["active"] = true
                alarm!["paired"] = true
                alarm!["partnerId"] = defaults.stringForKey("myId")
                alarm!.saveEventually()
                print("Updated partners")
            } else {
                NSLog("%@", error!)
            }
        }
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
