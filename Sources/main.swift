//
//  main.swift
//  calendarcsv
//
//  Created by Xi Fu on 6/26/17.
//  Copyright © 2017 Xi Fu. All rights reserved.
//

import EventKit
import Foundation

var standardError = FileHandle.standardError

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

let eventStore = EKEventStore()
let daysToSynchronize = Int(CommandLine.arguments[1])
let datefor = DateFormatter()

datefor.dateFormat = "yyyy-MM-dd HH:mm:ss"

func checkCalendarAuthorizationStatus() {
    let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
    
    switch (status) {
    case EKAuthorizationStatus.notDetermined:
        
        requestAccessToCalendar()
        
    case EKAuthorizationStatus.authorized:
        
        print("Done", to:&standardError)
        
        
    case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
        // We need to help them give us permission
        print("Denied", to:&standardError)
    }
}

func requestAccessToCalendar() {
    eventStore.requestAccess(to: EKEntityType.event, completion: {
        (accessGranted: Bool, error: Error?) in
        
        if accessGranted == true {
            print("Granted", to:&standardError)
        } else {
            print("Need permissions", to:&standardError)
        }
    })
}

checkCalendarAuthorizationStatus()

eventStore.enumerateEvents(matching:eventStore.predicateForEvents(withStart: Date().addingTimeInterval(TimeInterval(-1*daysToSynchronize!*60*60*24)), end: Date(), calendars: nil), using:{
    (event:EKEvent, stop:UnsafeMutablePointer<ObjCBool>) in
    
    print(datefor.string(from: event.startDate), datefor.string(from: event.endDate), event.title, event.calendar.title, separator: "\t")
    
})


