import Foundation

struct Item: Codable {
    var title: String
    var description: String
    var progressStatus: String
    var timeStamp: Int
    var dueDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(timeStamp))
    }
    var dateToString: String {
        return DateFormatter().convertDateToString(date: dueDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case title, description, progressStatus, timeStamp
    }
    
    mutating func updateItem(_ item: Item) {
        self.title = item.title
        self.description = item.description
        self.progressStatus = item.progressStatus
        self.timeStamp = item.timeStamp
    }
    
    mutating func updateProgressStatus(with progressStatus: String) {
        self.progressStatus = progressStatus
        if self.progressStatus == ProgressStatus.done.rawValue {
            notificationManager.removeNofitication(name: "\(self.dueDate)")
        } else {
            notificationManager.configureNotification(name: "\(self.dueDate)", date: self.dueDate)
        }
    }
}
