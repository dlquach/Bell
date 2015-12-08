//
//  SetAlarmController.swift
//  Bell
//
//  Created by Derek Quach on 12/6/15.
//  Copyright © 2015 Derek Quach. All rights reserved.
//

import Foundation
import UIKit
import Parse


class SetAlarmController: UIViewController {
    
    @IBOutlet weak var setAlarmButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    let LENGTH_OF_ALARM = 5.0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setAlarmButtonPressed(sender: AnyObject) {

        // If there is an active pairing, ask the user for confirmation
        // if they want to remove it and create a new alarm. 
        ClockController.removeExistingPairing()
        
        // If the date collected is BEFORE the current time, advance it by a day.
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        if datePicker.date.isLessThanDate(NSDate()) {
            datePicker.date = datePicker.date.addDays(1)
        }

        self.createNewAlarmAndSubmit(datePicker.date)
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    func createNewAlarmAndSubmit(date: NSDate) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(datePicker.date, forKey: "alarmTime")

        // Modify your AlarmObject
        let query = PFQuery(className: "AlarmObject")
        query.getObjectInBackgroundWithId(defaults.stringForKey("myId")!) {
            (alarm: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                alarm!.setObject(date, forKey: "dateTime")
                alarm!.setObject(true, forKey: "active")
                alarm!.setObject(false, forKey: "paired")
                alarm!.setObject("", forKey: "partnerId")
                alarm!.setObject("", forKey: "partnerName")
                alarm!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    defaults.setObject(true, forKey: "isAlarmActive")
                    UIApplication.sharedApplication().cancelAllLocalNotifications()
                    ClockController.queueUpLocalNotifications(date)
                    print("Object has been saved.")
                    print("Set alarm", defaults.boolForKey("isAlarmActive"))
                    print("Notifications queued")
                }
            } else {
                NSLog("%@", error!)
            }
        }
    }
    
}
