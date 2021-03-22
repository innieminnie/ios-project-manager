import Foundation

class HistoryManager {
    static let shared = HistoryManager()
    
    var historyTitle: [String] = ["1","2","3"]
    var historyDate: [String] = ["11","22","33"]
    
    private init() {
        
    }
}

let historyManager = HistoryManager.shared
