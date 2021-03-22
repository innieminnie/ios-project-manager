import Foundation

class HistoryManager {
    static let shared = HistoryManager()
    
    var historyTitle: [String] = []
    var historyDate: [String] = []
    var modifyTitle: [String] = []
    
    private init() {
    
    }
}

let historyManager = HistoryManager.shared
