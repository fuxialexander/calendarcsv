import EventKit

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
        
        print("Done.")
        
        
    case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
        // We need to help them give us permission
        print("Denied")
    }
}

func requestAccessToCalendar() {
    eventStore.requestAccess(to: EKEntityType.event, completion: {
        (accessGranted: Bool, error: Error?) in
        
        if accessGranted == true {
            print("Granted")
        } else {
            print("Need permissions")
        }
    })
}

checkCalendarAuthorizationStatus()

eventStore.enumerateEvents(matching:eventStore.predicateForEvents(withStart: Date().addingTimeInterval(TimeInterval(-1*daysToSynchronize*60*60*24)), end: Date().addingTimeInterval(TimeInterval(1*daysToSynchronize*60*60*24)), calendars: nil), using:{
    (event:EKEvent, stop:UnsafeMutablePointer<ObjCBool>) in
    
    print(datefor.string(from: event.startDate), datefor.string(from: event.endDate), event.title, event.calendar.title, separator: "\t")
    
})


