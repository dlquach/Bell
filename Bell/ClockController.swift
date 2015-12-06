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
    var testObject = PFObject(className: "AlarmObject")
    var parseLoop = NSTimer()
    var timer = NSTimer()
    var alarmTime:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Display the current time.
        timeLabel.text = getCurrentTime()
        
        // Set up the tick timer.
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        let query = PFQuery(className: "AlarmObject")
        query.getObjectInBackgroundWithId("AjOpz8E0Nx") {
            (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                object!["active"] = "true"
                object!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Object has been saved.")
                }
            } else {
                NSLog("%@", error!)
            }
        }
    }
    
    @IBAction func parseButtonPressed(sender: AnyObject) {
        let query = PFQuery(className: "AlarmObject")
        query.getObjectInBackgroundWithId("AjOpz8E0Nx") {
            (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                object!["active"] = "false"
                object!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Object has been saved.")
                }
            } else {
                NSLog("%@", error!)
            }
        }
    }
    
    func waitForStopMessage() {
        parseLoop = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "getParseObjects", userInfo: nil, repeats: true)
    }
    
    func getParseObjects() {
        let query = PFQuery(className: "AlarmObject")
        query.getObjectInBackgroundWithId("AjOpz8E0Nx")	 {
            (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                print(object!["active"] as! String)
                if object!["active"] as! String == "false" {
                    self.audioPlayer.stop()
                }
                else {
                    self.audioPlayer.play()
                }
            } else {
                NSLog("%@", error!)
            }
        }
    }
    
    func getCurrentTime() -> String {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }
    
    func tick() {
        let theTime = getCurrentTime()
        
        // Display the current time.
        if timeLabel.text != theTime {
            timeLabel.text = theTime
        }
        
        // Check if am alarm should be triggered.
        let defaults = NSUserDefaults.standardUserDefaults()
        if let alarmTime = defaults.stringForKey("alarmTime") {
            print("Alarm at", alarmTime)
            if alarmTime == theTime {
                if !parseLoop.valid {
                    waitForStopMessage()
                }
            }
            else {
                print("Alarm is at", alarmTime, "but it is", theTime)
            }
        }
        else {
            print("No alarm set")
        }
        
    }
}

