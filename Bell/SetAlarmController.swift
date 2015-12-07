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
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        print("Selected", formatter.stringFromDate(datePicker.date))
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(datePicker.date, forKey: "alarmTime")

        // Modify your AlarmObject
        let query = PFQuery(className: "AlarmObject")
        query.getObjectInBackgroundWithId(defaults.stringForKey("myId")!) {
            (alarm: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                alarm!.setObject(self.datePicker.date, forKey: "dateTime")
                alarm!.setObject(true, forKey: "active")
                alarm!.setObject(false, forKey: "paired")
                alarm!.setObject("", forKey: "partnerId")
                alarm!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    defaults.setObject(true, forKey: "isAlarmActive")
                    ClockController.queueUpLocalNotifications(self.datePicker.date)
                    print("Object has been saved.")
                    print("Set alarm", defaults.boolForKey("isAlarmActive"))
                    print("Notifications queued")
                }
            } else {
                NSLog("%@", error!)
            }
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
