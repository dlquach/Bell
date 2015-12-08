//
//  Util.swift
//  Bell
//
//  Created by Derek Quach on 12/7/15.
//  Copyright © 2015 Derek Quach. All rights reserved.
//

import Foundation

extension NSDate {
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
    return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
    return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
    }
    
    func addDays(daysToAdd : Int) -> NSDate
{
    let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
    
    return self.dateByAddingTimeInterval(secondsInDays)
    }
    
    
    func addHours(hoursToAdd : Int) -> NSDate
{
    let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
    
    return self.dateByAddingTimeInterval(secondsInHours)
    }
}