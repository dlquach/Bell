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
        let myQuery = PFQuery(className: "AlarmObject")
        
        if let myId = defaults.stringForKey("myId") {
            myQuery.getObjectInBackgroundWithId(myId) {
            (object: PFObject?, error: NSError?) -> Void in
                if (error == nil) {
                    object!["active"] = true
                    object!["paired"] = true
                    object!["partnerId"] = partnerId
                    object!.setObject(alarmTime, forKey: "dateTime")
                    object!.saveEventually()
                    print("Updated self")
                } else {
                    NSLog("%@", error!)
                }
            }
            
            defaults.setObject(true, forKey: "isAlarmActive")
            
            print("2", partnerId)
            let partnerQuery = PFQuery(className: "AlarmObject")
            partnerQuery.getObjectInBackgroundWithId(partnerId) {
                (object: PFObject?, error: NSError?) -> Void in
                if (error == nil) {	
                    object!["active"] = true
                    object!["paired"] = true
                    object!["partnerId"] = defaults.stringForKey("myId")
                    object!.saveEventually()
                    print("Updated partners")
                } else {
                    NSLog("%@", error!)
                }
            }
            
                
        }
        else {
            // Create an alarm object for yourself. TODO: This can be cleaned up.
            let alarm = PFObject(className: "AlarmObject")
            alarm.setObject(defaults.stringForKey("userName")!, forKey: "userName")
            alarm.setObject(alarmTime, forKey: "dateTime")
            alarm.setObject(true, forKey: "active")
            alarm.setObject(true, forKey: "paired")
            alarm.setObject(partnerId, forKey: "partnerId")
            alarm.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                print("Object has been saved.")
                defaults.setObject(alarm.objectId! as String, forKey: "myId")
                
                defaults.setObject(true, forKey: "isAlarmActive")
                
                print("2", partnerId)
                let partnerQuery = PFQuery(className: "AlarmObject")
                partnerQuery.getObjectInBackgroundWithId(partnerId) {
                    (object: PFObject?, error: NSError?) -> Void in
                    if (error == nil) {
                        object!["active"] = true
                        object!["paired"] = true
                        object!["partnerId"] = defaults.stringForKey("myId")
                        object!.saveEventually()
                        print("Updated partners")
                    } else {
                        NSLog("%@", error!)
                    }
                }
                
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
