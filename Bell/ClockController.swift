//
//  ViewController.swift
//  adasdas
//
//  Created by Derek Quach on 12/3/15.
//  Copyright © 2015 Derek Quach. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import Parse

class ClockController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    var audioPlayer = AVAudioPlayer()
    var parseLoop = NSTimer()
    var timer = NSTimer()
    var alarmTime:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Display the current time.
        timeLabel.text = getCurrentTime()
        
        // Check to see if user has registered.
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("userName") == nil) {
            let altMessage = UIAlertController(title: "Welcome to Bell!", message: "Please enter your name.", preferredStyle: UIAlertControllerStyle.Alert)
            altMessage.addTextFieldWithConfigurationHandler {
                (textField) -> Void in
                textField.placeholder = "Your name..."
            }
            altMessage.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    // "Register" the user by creating their alarm object
                    let user = PFObject(className: "AlarmObject")
                    let userName = ((altMessage.textFields?[0])! as UITextField).text
                    user.setObject(userName!, forKey: "userName")
                    user.setObject(NSDate(), forKey: "dateTime")
                    user.setObject(false, forKey: "active")
                    user.setObject(false, forKey: "paired")
                    user.setObject("", forKey: "partnerId")

                    user.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        print("Object has been saved.")
                        defaults.setObject(user.objectId! as String, forKey: "myId")
                        defaults.setObject(false, forKey: "isAlarmActive")
                        defaults.setObject(userName!, forKey: "userName")
                        self.setupTick()
                    }
                
                }))
            self.presentViewController(altMessage, animated: true, completion: nil)
        }
        else {
            setupTick()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let query = PFQuery(className: "AlarmObject")
        query.getObjectInBackgroundWithId(defaults.stringForKey("myId")!) {
            (alarm: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                alarm!["active"] = "true"
                alarm!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Object has been saved.")
                }
            } else {
                NSLog("%@", error!)
            }
        }
    }
    
    @IBAction func stopButtonPressed(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Disable your partner's alarm if you have one
        if let partnerId = defaults.stringForKey("partnerId") {
        print(partnerId)
        let query = PFQuery(className: "AlarmObject")
            query.getObjectInBackgroundWithId(partnerId) {
                (alarm: PFObject?, error: NSError?) -> Void in
                if (error == nil) {
                    alarm!["active"] = false
                    alarm!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Object has been saved.")
                    }
                } else {
                    NSLog("%@", error!)
                }
            }
        }
    }
    
    func setupTick() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil, repeats: true)
        
        let alertSound = NSBundle.mainBundle().URLForResource("alarm", withExtension: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound!)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
        } catch {
                print("Alarm sound broke")
        }
    }
    
    func waitForStopMessage() {
        parseLoop = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "handleAlarmObjectState", userInfo: nil, repeats: true)
    }
    
    func handleAlarmObjectState() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let myId = defaults.stringForKey("myId")
        let query = PFQuery(className: "AlarmObject")
        query.getObjectInBackgroundWithId(myId!)	 {
            (alarm: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                if (alarm!["active"] as! Bool) == false {
                    self.audioPlayer.stop()
                    self.parseLoop.invalidate()
                    defaults.setObject(false, forKey: "isAlarmActive")
                    UIApplication.sharedApplication().cancelAllLocalNotifications()
                    print("Set alarm", defaults.boolForKey("isAlarmActive"))
                }
                else {
                    self.audioPlayer.play()
                }
                
                // Update your partnerId
                if alarm!["paired"] as! Bool {
                    defaults.setObject(alarm!["partnerId"] as! String, forKey: "partnerId")
                }
            } else {
                NSLog("%@", error!)
            }
        }
    }
   
    func getCurrentTime() -> String {
        let date = NSDate()
        return ClockController.convertDateToHM(date)
    }
    
    func tick() {
        let theTime = getCurrentTime()
        
        // Display the current time.
        if timeLabel.text != theTime {
            timeLabel.text = theTime
        }
        let defaults = NSUserDefaults.standardUserDefaults()

        // Always check to see if alarms need to be stopped
        if defaults.boolForKey("isAlarmActive") {
            print("we active")
            // Check if am alarm should be triggered.
            let defaults = NSUserDefaults.standardUserDefaults()
            if let alarmTime = defaults.objectForKey("alarmTime") {
                let stringTime = ClockController.convertDateToHM(alarmTime as! NSDate)
                if stringTime == theTime {
                    if !parseLoop.valid {
                        waitForStopMessage() 
                    }
                }
                else {
                    print("Alarm is at", stringTime, "but it is", theTime)
                }
            }
            
        }
        else {
            print ("nope")
            self.audioPlayer.stop()
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }

    // Class functions that should be moved elsewhere eventaully
    class func convertDateToHM(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }
    
    class func queueUpLocalNotifications(var alarmTime: NSDate) {
        let LENGTH_OF_ALARM = 5.0
        
        // Strip seconds from the date
        let timeInterval = floor(alarmTime.timeIntervalSinceReferenceDate / 60.0) * 60.0
        alarmTime = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        
        for index in 0...50 {
            let notification = UILocalNotification()
            notification.alertBody = "Wake up!!"
            notification.alertAction = "open"
            notification.fireDate = (alarmTime).dateByAddingTimeInterval(Double(index) * LENGTH_OF_ALARM)
            notification.soundName = "alarm.mp3"
            notification.userInfo = ["UUID": "Test", ] // UUID
            notification.category = "TODO_CATEGORY"
            
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
}

