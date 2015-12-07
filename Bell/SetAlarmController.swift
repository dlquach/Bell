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
        
        let userName = defaults.stringForKey("userName")

        // Create an AlarmObject
        let alarm = PFObject(className: "AlarmObject")
        alarm.setObject(userName!, forKey: "userName")
        alarm.setObject(datePicker.date, forKey: "dateTime")
        alarm.setObject(true, forKey: "active")
        alarm.setObject(false, forKey: "paired")
        alarm.setObject("", forKey: "partnerId")

        alarm.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Object has been saved.")
            defaults.setObject(alarm.objectId! as String, forKey: "myId")
            defaults.setObject(true, forKey: "isAlarmActive")
            ClockController.queueUpLocalNotifications(self.datePicker.date)
        }
        
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
