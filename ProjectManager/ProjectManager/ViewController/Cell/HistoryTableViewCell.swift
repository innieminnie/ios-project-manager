import UIKit

class HistoryTableViewCell: UITableViewCell {
    let historyVC = HistoryViewController()
    static let identifier = "HistoryCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    func configureLabel(with index: Int) {
        self.title.text = historyManager.historyTitle[index]
        self.subTitle.text = historyManager.historyDate[index]
    }
}
