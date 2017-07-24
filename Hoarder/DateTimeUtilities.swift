//
//  DateTimeUtilities.swift
//  Hoarder
//
//  Created by Huan Cung on 7/22/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation

public class DateTimeUtilities {
    static let sharedInstance = DateTimeUtilities()
    
    static func formatTimeInterval(timeInterval: Double) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d,yyyy hh:mma" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    static func getTimestamp() -> Double {
        return NSDate().timeIntervalSince1970
    }
    
    static func getCurrentDate() -> String {
        return formatTimeInterval(timeInterval: getTimestamp())
    }
}
