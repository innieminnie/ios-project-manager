# 프로젝트매니저 칸반보드 📝

> <br> 해야할 일정에 대해 <b>TODO, DOING,DONE</b> 으로 나눈 칸반보드로 관리합니다.<br><br>

| 일정 추가하기 | 일정 수정하기 |
| - | - |
| <img src = "/image/ProjectManager_sheetviewcontroller.gif" width="400px"> | <img src = "/image/ProjectManager_editmode.gif" width="400px"> |  <img src = "/image/ProjectManager_draganddrop.gif" width="400px"> |

| 일정 상태 변경하기 | 일정 삭제하기 | 
| - | - |
| <img src = "/image/ProjectManager_draganddrop.gif" width="400px"> | <img src = "/image/ProjectManager_delete.gif" width="400px"> |

| 이전 수행 목록 확인(history) | 되돌리기/다시수행하기(undo/redo) |
| - | - |
| <img src = "/image/ProjectManager_historyviewcontroller.gif" width="400px"> | <img src = "/image/ProjectManager_undoredo.gif" width="400px"> |


---
## 주요 구현 사항
| ViewController | 기능 |
| - | - |
| ProjectManagerViewController | 칸반보드 표현 및 기능을 위한 버튼 제공
| SheetViewController  | 새로운 아이템 등록 및 아이템 내용 수정을 위한 폼 제공|
| HistoryViewController | 이전 수행 목록 제공 |
<br>

### 1 - 1 - 1 ) ProjectManagerViewController
#### 🤔 ProjectManagerViewController의 구조를 어떻게 할까?
- 고민점
    1. 3개 각각의 UITableView ( todoTableView, doingTableView, doneTableView) 를 하나의 View 내부에 배치하기

    1. ✅ UICollectionViewCell 내에 UITableView 및 UITableViewCell 을 배치하기 ✅<br><br>
- 2번방식 선정 이유
    <b> 1) ProjectManagerViewController 
    2) SectionCollectionViewCell
    3) boardTableView </b><br>    
    각각의 역할을 분리시키는 데 초점을 맞추기로 했습니다. UI구성의 복잡도는 비교적 높아졌지만,<br>
    ![projectmanager_projectmanagerviewcontroller](/image/ProjectManager_projectmanagerviewcontroller.png) 
    ![projectmanager_sectioncollectionviewcell](/image/ProjectManager_sectioncollectionviewcell.png)
    | ProjectManagerViewController | SectionCollectionViewCell | boardTableView |
    | - | - | - |
    |UINavigationBar의 <b>'+'</b> or <b>'history'</b>,<br> 하단의 <b>undo/redo</b> 버튼에 대한 액션 수행|Todo / Doing / Done 단위의 Board 관리|각 Board 내의 Item 관리|    
    - 하나의 SectionCollectionViewCell에서 하나의 boardTableView만 관리합니다.
    - boardTableView는 하나의 Board타입이 갖는 item의 배열만 대상으로 하여 tableViewCell에 표시합니다.<br><br>
### 1 - 1 - 2 ) ProjectManagerViewController - SectionCollectionViewCell - 일정 상태 변경 (Drag And Drop)
UITableViewDragDelegate 와  UITableViewDropDelegate 프로토콜을 준수하여 상태 변경을 구현했습니다.
- UITableViewDragDelegate
    ```swift
     func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider()
        
        let indexRow = indexPath.row
        
        session.localContext = (board, indexPath, tableView)
        return [UIDragItem(itemProvider: itemProvider)]
    }
    ```

    Drag하는 아이템 정보 ( 이동 시작하는 board, item의 indexPath, 이동 시작하는 tableView ) UIDragSession의 localContext에 담아 전달합니다.<br><br>

- UITableViewDropDelegate
    ```swift
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = tableView.numberOfRows(inSection: 0)
            destinationIndexPath = IndexPath(row: row, section: 0)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { [self] items in
            var sourceIndexPaths = [IndexPath]()
            if let (sourceBoard, sourceIndexPath, sourceTableView) = coordinator.session.localDragSession?.localContext as? (Board, IndexPath, UITableView) {
                sourceIndexPaths.append(sourceIndexPath)
                
                var indexPaths = [IndexPath]()
                let indexPath = IndexPath(row: destinationIndexPath.row, section: destinationIndexPath.section)
                
                if let board = self.board {
                    board.insertItem(at: indexPath.row, with: boardManager.boards[boardNumber].item(at: count))
                    board.items[indexPath.row].updateProgressStatus(with: board.title)
                    indexPaths.append(indexPath)
                    tableView.insertRows(at: indexPaths, with: .automatic)
                }
            }
            
            self.removeSourceTableData(localContext: coordinator.session.localDragSession?.localContext)
        }
    }
    ```
    destinationIndexPath (이동할 위치) 를 인식한 후, <b>coordinator.session.loadObjects</b> 에서 전달받은 정보를 알맞은 위치에 배치합니다.
#### 🤔 같은 TableView 내에서의 아이템 이동 시 셀의 아이템 변경이 알맞게 구현되지 않는다?
- <b>문제점</b>
    위의 구현 방식으로 SectionCollectionViewCell의 TableView에서 다른 SectionCollectionViewCell의 TableView로 이동 시, 기능이 적절하게 구현되었지만 같은 TableView내에서 이동 시(reordering) drag하는 item이 drag하는 아이템 내용이 복사되어 drop하는 곳에 중복되어 표시가 되었습니다.<br><br>

- <b>원인에 대한 추측</b>
    다른 테이블 간의 이동 시에는 removeSourceTableData를 통해 drag를 시작하는 테이블에서는 간단히 이동할 데이터를 삭제하고, drop하는 테이블에서는 insertRows를 통해 해당 데이터만 삽입해주면 됩니다. <br>  
    반면 같은 테이블 내에서 이동 시, sourceIndexPath와 destinationIndexPath가 동일한 tableView에 정보가 담겨 있기 때문에 removeSourceTableData 메소드를 호출하면 index 배치 상황에서 오류 발생 가능성이 있기에 드래그앤드롭 후 변경되는 indexPath를 전부 접근하여 업데이트해줘야 합니다. <br><br>

- <b>해결방안</b>
    같은테이블 내 이동하는 경우, 다른테이블로 이동하는 경우로 나눠 coordinator.session.loadObjects 메소드 내에서 분기 작업을 작성할 수 있지만, 각각 경우에 대한 코드 작성이 복잡함과 더불어 가독성이 떨어진다고 생각했고, 같은 테이블 내 이동 시 하나의 데이터 이동에 따른 indexPath가 변경되는 다른 데이터들에 대한 접근이 효율성이 떨어진다고 생각했습니다. 

    애플 공식문서에서 제시한 바에 따르면, <br><br>

    ![projectmanager_draganddrop_sametable](/image/ProjectManager_draganddrop_1.png)<br>
    와 같이 나와있어
 
    ```swift
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let board = self.board {
            let movingItem = board.item(at: sourceIndexPath.row)
            board.deleteItem(at: sourceIndexPath.row)
            board.insertItem(at: destinationIndexPath.row, with: movingItem)
        }
    }
    ```
    와 같이 UITableViewDelegate의 메소드를 통해 같은 테이블뷰내의 아이템 이동에 대해 개선해보았습니다.

### 1 - 1 - 3 ) ProjectManagerViewController - SectionCollectionViewCell - 일정 삭제
### 1 - 2 ) ProjectManagerViewController - 되돌리기/다시수행하기 (undo / redo)
- 화면 하단의 'Undo / Redo ' 버튼: 수행작업에 대한 되돌리기/ 다시수행하기 기능을 수행한다.
    ![projectmanager_undoredo](/image/ProjectManager_undoredo.png)
        <p align="center"><img src = "/image/ProjectManager_undoredo.gif" width="500px"></p>
#### 🤔 Undo/Redo 버튼의 동작 인식과 동작 수행을 모두 ProjectManagerViewController에서 다뤄야 할까?
- 고민점
    Undo/Redo 버튼의 액션은 ProjectManagerViewController에서 수행하지만, Undo/Redo의 대상은 SectionCollectionViewCell의 board에 담긴 item이다. Undo/Redo의 대상에게 어떻게 버튼 탭 액션에 따른 기능 수행을 요구해야할까?

- 해결방안
    <b>UndoManager</b>의 사용을 도입했습니다. UndoManager는 싱글톤타입으로 앱 전역에서 발생하는 이벤트에 대한 <b>Task Management</b>를 담당합니다. ProjectManagerViewController에선 버튼의 탭 동작에 따라 undoManager.undo(), undoManager.redo() 를 수행하며, SectionCollectionViewCell에선 아이템의 생성/이동/삭제 액션이 실행될 때마다 undoManager의 registerUndo() 메소드를 활용하여 동작을 등록합니다.
    | 타입명 | 메소드명 | 기능설명|
    | --- | --- | --- |
    | ProjectManagerViewController | registerUndoCreating() | item 생성에 대한 undo (item 생성 취소) 등록 |
    | ProjectManagerViewController | registerUndoDeleting(with item: Item, at index: Int) | item 삭제에 대한 undo (item 삭제 취소) 등록 |
    | SectionCollectionViewCell | registerRedoCreating(with item: Item) | item 생성에 대한 redo 등록 |
    | SectionCollectionViewCell| registerRedoDeleting(at index: Int) | item 삭제에 대한 redo 등록 |
    | SectionCollectionViewCell| registerUndoMoving(_ sourceIndexPaths: [IndexPath], _ sourceBoard: Board, _ sourceTableView: UITableView, _ indexPaths: [IndexPath]) | item 이동에 대한 undo (item 이동 취소) 등록 |
    | SectionCollectionViewCell | registerRedoMoving(_ indexPaths: [IndexPath], _ sourceBoard: Board, _ sourceTableView: UITableView, _ sourceIndexPaths: [IndexPath], _ destinationBoard: Board, _ destinationBoardTableView: UITableView) | item 이동에 대한 redo 등록 |

### 2 - 1 ) SheetViewController - 일정 추가
- ProjectManagerViewController의 UINavigationBar의 '+' 버튼: 새로운 할 일을 작성한다.

    ![projectmanager_sheetviewcontroller](/image/ProjectManager_sheetviewcontroller.png)
        <p align="center"><img src = "/image/ProjectManager_sheetviewcontroller.gif" width="500px"></p>
#### 🤔 SheetViewController에서 새로운 할 일 (item) 생성 후 SectionCollectionViewCell에 해당 item을 어떻게 전달할까?
- 고민점
    ProjectManagerViewController에서 '+' 버튼을 통해 modal로 present된 SheetViewController에서 새로운 할 일 등록 작업을 한 후, TODO 섹션에 해당하는 SectionCollectionViewCell의 tableView에 아이템이 추가되어야 합니다. <b>SectionCollectionViewCell 와 SheetViewController간의 관계</b>를 직접적으로 연결하는 구조를 피하기 위해 ProjectManagerViewController로 간접적으로 거쳐갈 수 있는 구조로 해당 기능을 수행하는 방향에 대해 고민했습니다.<br><br>
- 해결 방안
    | 타입명 | 수행 기능 |
    | - | - |
    |SectionCollectionViewCell| AddItemDelegate 프로토콜 준수 및 addNewCell 메소드 작성 |
    |ProjectManagerViewController|1) weak var delegate: AddItemDelegate <br>todoBoard를 대상으로 하는 SectionCollectionViewCell 설정<br> 2) SheetViewController의 updateItemHandler 호출 |
    |SheetViewController|1) var completionHandler: ((Item) -> Void)?<br> 2) updateItemHandler(handler: @escaping (_ item: Item) -> Void) 작성 | 
    <b>SectionCollectionViewCell</b>
    ```swift
    protocol AddItemDelegate: AnyObject {
        func addNewCell(with item: Item)
    }

    extension SectionCollectionViewCell: AddItemDelegate {
    func addNewCell(with item: Item) {
        if let board = self.board {
            board.addItem(item)
            boardTableView.insertRows(at: [IndexPath(row: board.itemsCount - 1, section: 0)], with: .automatic)
            updateHeaderLabels(with: board)
            self.registerUndoCreating()
            NotificationCenter.default.post(name: NSNotification.Name("reloadRewindable"), object: nil)
         }
        }
    }
    ```

    <b>SheetViewController</b>
    ```swift
    var completionHandler: ((Item) -> Void)?
    var currentItem = Item(title: "", description: "", progressStatus: "TODO", timeStamp: Int(Date().timeIntervalSince1970))

    func updateItemHandler(handler: @escaping (_ item: Item) -> Void) {
        completionHandler = handler
    }

    @IBAction private func tappedDoneButton(_ sender: Any) {

       ... 새로운 할 일 작성 (currentItem 설정부)...
        
        if let completionHandler = completionHandler {
            completionHandler(currentItem)
        }
        
        self.dismiss(animated: true, completion: nil)
        
        ...
    }

    ```

    <b>ProjectManagerViewController</b>
    ```swift
     @IBAction func tappedAddButton(_ sender: Any) {
        createNewTodoItem()
    }

    private func createNewTodoItem() {
        var newItem = boardManager.todoBoard.createItem()
        let presentedSheetViewController = presentSheetViewController(with: newItem, mode: Mode.editable)
        
        presentedSheetViewController.updateItemHandler { (currentItem) in
            newItem = currentItem
            newItem.progressStatus = ProgressStatus.todo.rawValue
            self.delegate = self.sectionCollectionView.cellForItem(at: [0,0]) as? SectionCollectionViewCell
            self.delegate?.addNewCell(with: newItem)
           
           ... 이후 다른 작업 수행 ...
        }
    }
    ```
### 2 - 2 ) SheetViewController - 일정 내용 수정하기

### 3) HistoryViewController
- UINavigationBar의 'history' 버튼:  할 일 생성/이동/삭제에 대한 기록을 저장한다.
    ![projectmanager_historyviewcontroller](/image/ProjectManager_historyviewcontroller.png)
        <p align="center"><img src = "/image/ProjectManager_historyviewcontroller.gif" width="500px"></p>
    HistoryViewController는 <b>UITableViewDataSource 프로토콜</b>을 준수합니다. 해당 ViewController의 <b>tableView는 히스토리 정보를 표현할 뿐,</b> tableView에 대한 어떠한 액션을 수행하는 것은 필요하지 않다 생각되어 UITableViewDelegate 프로토콜을 따로 준수하지 않습니다.
#### 🤔 "히스토리 내역을 로컬디스크에 저장해놓을 필요가 있을까?"
- 고민점
    앱의 할일 리스트(todo, doing, done) 전체와 비교해보았을 때, 인앱 상황에서 변경되는 히스토리들은 앱이 켜져있는 동안의 히스토리만 보여주자고 팀원과 의논해보았습니다. 만약 히스토리 내역 또한 로컬디스크에 캐싱을 한다면 데이터의 축적으로 인한 cache 관리 작업도 지속적으로 해줘야하고, 사용자에겐 <b>'언제' '어떤 것'이 '어떻게 변경' 되었는지</b>에 대한 정보보단 <b>'현재 할 일의 상태'</b>를 보여주는 것이 적합하다고 생각했습니다.<br><br>
- 해결방안
    | 타입명 | 수행 기능 |
    | - | - |
    |HistoryManager (Singleton)| historyContainer (HistoryLog, Date) 배열에 변경사항 관리 |

    ```swift
    class HistoryManager {
      static let shared = HistoryManager()
      var historyContainer = [(HistoryLog, Date)]()
    }
    let historyManager = HistoryManager.shared
    ``` 
    <br>

    싱글톤패턴 사용 이유: 앱 전역에서 발생하는 아이템 생성/이동/삭제 관련 내용에 대해 전부 추적해야하기 위해 싱글톤 HistoryManager 내의 historyContainer에 해당 내역들을 담아 tableView로 표현했습니다.<br><br>
---

### Point 2) 로컬디스크캐시
### Point 3) 지역화