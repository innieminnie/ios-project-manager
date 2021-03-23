import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    let content = UNMutableNotificationContent()
    
    func requestNotificationAuthorization() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        
        userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    func configureNotification(time: Double, name: String, date: Date) {
        content.title = "마감일"
        content.body = "금일 마감일이 도래한 목록이 있습니다."
        content.badge = 1
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: name, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
}

let notificationManager = NotificationManager.shared
