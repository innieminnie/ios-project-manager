import Foundation

class Board {
    let title: String
    var items = [Item]()
    var itemsCount: Int {
        return items.count
    }
    
    init(title: String) {
        self.title = title
    }
    
    func item(at index: Int) -> Item {
        return items[index]
    }
    
    func createItem() -> Item {
        return Item(title: "", description: "", progressStatus: "", timeStamp: Int(Date().timeIntervalSince1970))
    }
    
    func addItem(_ item: Item) {
        items.append(item)
    }
    
    func insertItem(at index: Int, with item: Item) {
        items.insert(item, at: index)
    }
    
    func updateItem(at index: Int, with item: Item) {
       items[index].updateItem(item)
        if item.progressStatus != ProgressStatus.done.rawValue {
            notificationManager.configureNotification(name: "\(item.dueDate)", date: item.dueDate)
        }
    }

    func deleteItem(at index: Int) {
        items.remove(at: index)
    }
}
