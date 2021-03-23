import Foundation

enum HistoryLog: CustomStringConvertible {
    case add(String)
    case move(String, String, String)
    case delete(String, String)
    
    var description: String {
        switch self {
        case .add(let title):
            return String(format: NSLocalizedString("Added '%@'.", comment: ""), title)
        case .move(let title, let before,  let after):
            return String(format: NSLocalizedString("Moved '%@' from %@ to %@.", comment: ""), title, before.localized, after.localized)
        case .delete(let title, let before):
            return String(format: NSLocalizedString("Removed '%@' from %@.", comment: ""), title.localized, before.localized)
        }
    }
}
