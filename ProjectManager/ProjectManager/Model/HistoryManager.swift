import Foundation

class HistoryManager {
    static let shared = HistoryManager()
    
    var historyTitle: [String] = []
    var historyDate: [String] = []
    
    private init() {
    
    }
    
    func setHistory(action: String, item: Item) {
        var modifyTitle: String
        var modifyDate: String
        
        switch action {
        case "Added":
            modifyTitle = "\(action) " + "'\(item.title)'."
            modifyDate = "Mar 11, 2020 3:32:07 PM"
            
        case "Removed":
            modifyTitle = "\(action) " + "'\(item.title)' " + "from " + "\(item.progressStatus)."
            modifyDate = "Mar 11, 2020 3:32:07 PM"
            
        default:
            modifyTitle = "\(action) " + "'\(item.title)' " + "from " + "\(item.progressStatus) " + "to " + "\(item.progressStatus)."
            modifyDate = "Mar 11, 2020 3:32:07 PM"
        }
        historyTitle.append(modifyTitle)
        historyDate.append(modifyDate)
    }
}

let historyManager = HistoryManager.shared
