import UIKit
import MobileCoreServices
import Network

protocol BoardTableViewCellDelegate: AnyObject {
    func tableViewCell(_ boardTableViewCell: BoardTableViewCell, didSelectAt index: Int, on board: Board?)
}

class ProjectManagerViewController: UIViewController {
    @IBOutlet weak var titleNavigationBar: UINavigationBar!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var sectionCollectionView: UICollectionView!
    @IBOutlet weak var networkLabel: UILabel!
    
    weak var delegate: AddItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureUndoRedoButton()
        configureNetworkMonitor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHeader), name: NSNotification.Name("reloadHeader"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRewindable), name: NSNotification.Name("reloadRewindable"), object: nil)
    }
    
    @IBAction func tappedAddButton(_ sender: Any) {
        createNewTodoItem()
    }
    
    @IBAction func tappedUndoButton(_ sender: UIButton) {
        self.undoManager?.undo()
        configureUndoRedoButton()
    }
    @IBAction func tappedRedoButton(_ sender: UIButton) {
        self.undoManager?.redo()
        configureUndoRedoButton()
    }
    
    @objc func reloadRewindable(_ noti: Notification) {
        configureUndoRedoButton()
    }
    
    @objc func reloadHeader(_ noti: Notification) {
        for item in 0..<sectionCollectionView.numberOfItems(inSection: 0) {
            if let sectionCollectionViewCell = sectionCollectionView.cellForItem(at: [0,item]) as? SectionCollectionViewCell, let cellBoard = sectionCollectionViewCell.board {
                sectionCollectionViewCell.updateHeaderLabels(with: cellBoard)
            }
        }
    }
}

// MARK: - UIColletionViewDataSource

extension ProjectManagerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardManager.boards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SectionCollectionViewCell.identifier, for: indexPath) as? SectionCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.updateHeaderLabels(with : boardManager.boards[indexPath.item])
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProjectManagerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewCellWidth = collectionView.frame.width / CGFloat(boardManager.boards.count) - 10
        let collectionViewCellHeight = collectionView.frame.height
        
        return CGSize(width: collectionViewCellWidth, height: collectionViewCellHeight)
    }
}

// MARK: - BoardTableViewCellDelegate

extension ProjectManagerViewController: BoardTableViewCellDelegate {
    func tableViewCell(_ boardTableViewCell: BoardTableViewCell, didSelectAt index: Int, on board: Board?) {
        notificationManager.removeNofitication(name: "\(String(describing: board?.item(at: index).dueDate))")
        if let board = board {
            updateItem(in: boardTableViewCell, at: index, on: board)
        }
    }
}

// MARK: - Extension ProjectManagerViewController

extension ProjectManagerViewController {
    private func configureNavigationBar() {
        titleNavigationBar.topItem?.title = "Project Manager".localized
    }
    
    private func configureUndoRedoButton() {
        undoButton.isEnabled = self.undoManager?.canUndo ?? false
        redoButton.isEnabled = self.undoManager?.canRedo ?? false
    }
    
    private func createNewTodoItem() {
        var newItem = boardManager.todoBoard.createItem()
        let presentedSheetViewController = presentSheetViewController(with: newItem, mode: Mode.editable)
        
        presentedSheetViewController.updateItemHandler { (currentItem) in
            newItem = currentItem
            newItem.progressStatus = ProgressStatus.todo.rawValue
            self.delegate = self.sectionCollectionView.cellForItem(at: [0,0]) as? SectionCollectionViewCell
            self.delegate?.addNewCell(with: newItem)
            
            let historyLog = HistoryLog.add(newItem.title)
            historyManager.historyContainer.append((historyLog, Date()))
            projectFileManager.updateFile()
        }
    }
    
    private func updateItem(in boardTableViewCell: BoardTableViewCell, at index: Int, on board: Board) {
        let item = board.item(at: index)
        let presentedSheetViewController = presentSheetViewController(with: item, mode: Mode.readOnly)
        
        presentedSheetViewController.updateItemHandler { (currentItem) in
            board.updateItem(at: index, with: currentItem)
            boardTableViewCell.updateUI(with: currentItem)
            projectFileManager.updateFile()
        }
    }
    
    private func presentSheetViewController(with item: Item, mode: Mode) -> SheetViewController {
        guard let sheetViewController = self.storyboard?.instantiateViewController(identifier: SheetViewController.identifier) as? SheetViewController else {
            return SheetViewController()
        }
        
        sheetViewController.modalPresentationStyle = .formSheet
        sheetViewController.setItem(with: item)
        sheetViewController.mode = mode
        self.present(sheetViewController, animated: true, completion: nil)
        
        return sheetViewController
    }
}

// MARK: - Popover

extension ProjectManagerViewController: UIPopoverPresentationControllerDelegate {
    @IBAction func showHistory(_ sender: Any) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "history") as! HistoryViewController
        popoverContent.modalPresentationStyle = .popover
        if let popover = popoverContent.popoverPresentationController {
            let viewForSource = sender as! UIView
            popover.sourceView = viewForSource
            popover.sourceRect = viewForSource.bounds
            popoverContent.preferredContentSize = CGSize(width: 600,height: 600)
            popover.delegate = self
        }
        
        self.present(popoverContent, animated: true, completion: nil)
    }
}

// MARK: - Check the Network Connection

extension ProjectManagerViewController {
    func configureNetworkMonitor() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            
            if path.status != .satisfied {
                print("네트워크에 연결되어 있지 않습니다.")
                DispatchQueue.main.async {
                    self.networkLabel.isHidden = false
                }
            } else {
                print("네트워크에 연결되어 있습니다.")
                DispatchQueue.main.async {
                    self.networkLabel.isHidden = true
                }
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
}
