import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    let content = UNMutableNotificationContent()
    let center = UNUserNotificationCenter.current()
    
    func requestNotificationAuthorization() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        
        userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    func configureNotification(name: String, date: Date) {
        content.title = "마감일"
        content.body = "금일 마감일이 도래한 목록이 있습니다."
        content.badge = 1
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 9
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: name, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
        
        print(center.getPendingNotificationRequests(completionHandler: {requests in
            for request in requests {
                print(request)
            }
        }))
    }
    
    func removeNofitication(name: String) {
        center.removePendingNotificationRequests(withIdentifiers: [name])
        
        print(center.getPendingNotificationRequests(completionHandler: {requests in
            for request in requests {
                print(request)
            }
        }))
    }
}

let notificationManager = NotificationManager.shared
