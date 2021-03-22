import UIKit

class HistoryTableViewCell: UITableViewCell {
    let historyVC = HistoryViewController()
    static let identifier = "HistoryCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    func configureLabel() {
        self.title.text = historyVC.item[0]
        self.subTitle.text = historyVC.itemInfo[0]
    }
}
