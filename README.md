# 프로젝트매니저 칸반보드 📝

> <br> 해야할 일정에 대해 <b>TODO, DOING,DONE</b> 으로 나눈 칸반보드로 관리합니다.<br><br>

| 일정 추가하기 | 일정 수정하기 |
| - | - |
| <img src = "/image/ProjectManager_sheetviewcontroller.gif" width="400px"> | <img src = "/image/ProjectManager_editmode.gif" width="400px"> |

| 일정 상태 변경하기 | 일정 삭제하기 | 
| - | - |
| <img src = "/image/ProjectManager_draganddrop.gif" width="400px"> | <img src = "/image/ProjectManager_delete.gif" width="400px"> |

| 이전 수행 목록 확인(history) | 되돌리기/다시수행하기(undo/redo) |
| - | - |
| <img src = "/image/ProjectManager_historyviewcontroller.gif" width="400px"> | <img src = "/image/ProjectManager_undoredo.gif" width="400px"> |


---
## 주요 학습 내용
- 테이블뷰의 Drag and Drop 구현
    - [SectionCollectionViewCell의 일정 상태 변경 (Drag And Drop) 기능](#sectioncollectionviewcell의-일정-상태-변경-drag-and-drop-기능)
    - [:thinking: 같은 TableView 내에서의 아이템 이동 시 셀의 아이템 변경이 알맞게 구현되지 않는다?](#thinking-같은-tableview-내에서의-아이템-이동-시-셀의-아이템-변경이-알맞게-구현되지-않는다)
- Undo Manager의 활용
    - [:thinking: Undo와Redo 버튼의 동작 인식과 동작 수행을 모두 ProjectManagerViewController에서 다뤄야 할까?](#thinking-undo와redo-버튼의-동작-인식과-동작-수행을-모두-projectmanagerviewcontroller에서-다뤄야-할까)
- 로컬 디스크 캐시 구현
    - [iOS File System 및 FileManager 블로그 포스팅 글 보러가기 (페이지 이동)](https://innieminnie.github.io/filesystem/filemanager/2021/05/30/FileManager.html)
    - [Point 2) 로컬디스크캐시](#point-2-로컬디스크캐시)
- 지역화(localization) 구현
    - [지역화 블로그 포스팅 글 보러가기 (페이지 이동)](https://innieminnie.github.io/localization/internalization/2021/06/02/Localization.html)

## 트러블슈팅 모아보기
- [:thinking: 다수의 TableView를 어떤 방식으로 배치할 것인가?   (CollectionViewCell내 TableView 배치하기)](#thinking-다수의-tableview를-어떤-방식으로-배치할-것인가-collectionviewcell내-tableview-배치하기)
- [:thinking: 같은 TableView 내에서의 아이템 이동 시 셀의 아이템 변경이 알맞게 구현되지 않는다?](#thinking-같은-tableview-내에서의-아이템-이동-시-셀의-아이템-변경이-알맞게-구현되지-않는다)
- [:thinking: Undo와Redo 버튼의 동작 인식과 동작 수행을 모두 ProjectManagerViewController에서 다뤄야 할까?](#thinking-undo와redo-버튼의-동작-인식과-동작-수행을-모두-projectmanagerviewcontroller에서-다뤄야-할까)
- [:thinking: SheetViewController에서 새로운 할 일 (item) 생성 후 SectionCollectionViewCell에 해당 item을 어떻게 전달할까?(CompletionHandler 활용하기)](#thinking-sheetviewcontroller에서-새로운-할-일-item-생성-후-sectioncollectionviewcell에-해당-item을-어떻게-전달할까)
- [:thinking: 일정 추가 기능과 일정 수정 기능의 구현부를 공통적으로 추출할 수 있지 않을까?(CompletionHandler 활용성 높이기)](#thinking-일정-추가-기능과-일정-수정-기능의-구현부를-공통적으로-추출할-수-있지-않을까)
- [:thinking: 일정 수정 후, 일정을 나타내는 BoardTableViewCell의 layout이 업데이트 되지 않는다?](#thinking-일정-수정-후-일정을-나타내는-boardtableviewcell의-layout이-업데이트-되지-않는다)
- [:thinking: 히스토리 내역을 로컬디스크에 저장할까?](#thinking-히스토리-내역을-로컬디스크에-저장할까)
- [:thinking: HistoryLog 출력시, description을 자동으로 출력할 순 없을까?](#thinking-historylog-출력시-description을-자동으로-출력할-순-없을까)
---
## Point 1) 주요 구현 사항
| ViewController | 기능 |
| - | - |
| ProjectManagerViewController | 칸반보드 표현 및 기능을 위한 버튼 제공
| SheetViewController  | 새로운 아이템 등록 및 아이템 내용 수정을 위한 폼 제공|
| HistoryViewController | 이전 수행 목록 제공 |
<br>

## ProjectManagerViewController
### ProjectManagerViewController의 구조
### :thinking: 다수의 TableView를 어떤 방식으로 배치할 것인가?(CollectionViewCell내 TableView 배치하기)
- 고민점
    1. 3개 각각의 UITableView ( todoTableView, doingTableView, doneTableView) 를 하나의 View 내부에 배치하기

    1. ✅ UICollectionViewCell 내에 UITableView 및 UITableViewCell 을 배치하기 ✅<br><br>
- 2번방식 선정 이유<br>
    <b> 1) ProjectManagerViewController 
    2) SectionCollectionViewCell
    3) boardTableView </b><br>    
    각각의 역할을 분리시키는 데 초점을 맞추기로 했습니다.<br>
    ![projectmanager_projectmanagerviewcontroller](/image/ProjectManager_projectmanagerviewcontroller.png) 
    ![projectmanager_sectioncollectionviewcell](/image/ProjectManager_sectioncollectionviewcell.png)
    | ProjectManagerViewController | SectionCollectionViewCell | boardTableView |
    | - | - | - |
    |UINavigationBar의 <b>'+'</b> or <b>'history'</b>,<br> 하단의 <b>undo/redo</b> 버튼에 대한 액션 수행|Todo / Doing / Done 단위의 Board 관리|각 Board 내의 Item 관리|    
    - 하나의 SectionCollectionViewCell에서 하나의 boardTableView만 관리합니다.
    - boardTableView는 하나의 Board타입이 갖는 item의 배열만 대상으로 하여 tableViewCell에 표시합니다.<br><br>
### SectionCollectionViewCell의 일정 상태 변경 (Drag And Drop) 기능
<b>UITableViewDragDelegate</b> 와  <b>UITableViewDropDelegate</b> 프로토콜을 준수하여 상태 변경을 구현했습니다.
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

### :thinking: 같은 TableView 내에서의 아이템 이동 시 셀의 아이템 변경이 알맞게 구현되지 않는다?
- <b>문제점</b><br>
    SectionCollectionViewCell의 TableView에서 다른 SectionCollectionViewCell의 TableView로 이동 시, 기능이 적절하게 구현되었지만 같은 TableView내에서 이동 시(reordering) drag하는 item이 drag하는 아이템 내용이 복사되어 drop하는 곳에 중복되어 표시가 되었습니다.<br><br>

- <b>원인</b><br>
    다른 테이블 간의 이동 시에는 removeSourceTableData를 통해 drag를 시작하는 테이블에서는 이동할 데이터를 삭제하고, drop하는 테이블에서는 insertRows를 통해 해당 데이터만 삽입해주면 됩니다. <br>  
    반면 같은 테이블 내에서 이동 시, sourceIndexPath와 destinationIndexPath가 동일한 tableView에 정보가 담겨 있기 때문에 removeSourceTableData 메소드를 호출하면 index 배치 상황에서 오류 발생 가능성이 있기에 드래그앤드롭 후 변경되는 indexPath를 전부 접근하여 업데이트해줘야 합니다. <br><br>

- <b>해결방안</b><br>
    같은테이블 내 이동하는 경우과 다른테이블로 이동하는 경우로 나눠 coordinator.session.loadObjects 메소드 내에서 분기 작업을 작성할 수 있지만, 각각 경우에 대한 코드 작성이 복잡함과 더불어 가독성이 떨어진다고 생각했고, 같은 테이블 내 이동 시 하나의 데이터 이동에 따른 indexPath가 변경되는 다른 데이터들에 대한 접근이 효율성이 떨어진다고 생각했습니다. 

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
   같은 테이블뷰내의 아이템 이동에 대해 UITableViewDelegate의 메소드를 통해 개선해보았습니다.

### ProjectManagerViewController의 되돌리기/다시수행하기 (undo/redo) 기능
- 화면 하단의 'Undo / Redo ' 버튼: 수행작업에 대한 되돌리기/ 다시수행하기 기능을 수행한다.
    ![projectmanager_undoredo](/image/ProjectManager_undoredo.png)
        <p align="center"><img src = "/image/ProjectManager_undoredo.gif" width="500px"></p>

### :thinking: Undo와Redo 버튼의 동작 인식과 동작 수행을 모두 ProjectManagerViewController에서 다뤄야 할까?
- 고민점<br>
    Undo/Redo 버튼의 액션은 ProjectManagerViewController에서 수행하지만, Undo/Redo의 대상은 SectionCollectionViewCell의 board에 담긴 item이다. Undo/Redo의 대상에게 어떻게 버튼 탭 액션에 따른 기능 수행을 요구해야할까?

- 해결방안<br>
    <b>UndoManager</b>의 사용을 도입했습니다. UndoManager는 싱글톤타입으로 앱 전역에서 발생하는 이벤트에 대한 <b>Task Management</b>를 담당합니다. 
    
    ProjectManagerViewController - 버튼의 탭 동작에 따라 undoManager.undo(), undoManager.redo() 를 수행합니다.
    
     SectionCollectionViewCell - 아이템의 생성/이동/삭제 액션이 실행될 때마다 undoManager의 registerUndo() 메소드를 활용하여 동작을 등록합니다.<br><br>


    | 타입명 | 메소드명 | 기능설명|
    | --- | --- | --- |
    | ProjectManagerViewController | registerUndoCreating() | item 생성에 대한 undo (item 생성 취소) 등록 |
    | ProjectManagerViewController | registerUndoDeleting(with item: Item, at index: Int) | item 삭제에 대한 undo (item 삭제 취소) 등록 |
    | SectionCollectionViewCell | registerRedoCreating(with item: Item) | item 생성에 대한 redo 등록 |
    | SectionCollectionViewCell| registerRedoDeleting(at index: Int) | item 삭제에 대한 redo 등록 |
    | SectionCollectionViewCell| registerUndoMoving(_ sourceIndexPaths: [IndexPath], _ sourceBoard: Board, _ sourceTableView: UITableView, _ indexPaths: [IndexPath]) | item 이동에 대한 undo (item 이동 취소) 등록 |
    | SectionCollectionViewCell | registerRedoMoving(_ indexPaths: [IndexPath], _ sourceBoard: Board, _ sourceTableView: UITableView, _ sourceIndexPaths: [IndexPath], _ destinationBoard: Board, _ destinationBoardTableView: UITableView) | item 이동에 대한 redo 등록 |

---
## SheetViewController
### SheetViewController의 일정 추가 기능
- ProjectManagerViewController의 UINavigationBar의 '+' 버튼: 새로운 할 일을 작성한다.

    ![projectmanager_sheetviewcontroller](/image/ProjectManager_sheetviewcontroller.png)
        <p align="center"><img src = "/image/ProjectManager_sheetviewcontroller.gif" width="500px"></p>
### :thinking: SheetViewController에서 새로운 할 일 (item) 생성 후 SectionCollectionViewCell에 해당 item을 어떻게 전달할까?
- 고민점<br>
    ProjectManagerViewController에서 '+' 버튼을 통해 modal로 present된 SheetViewController에서 새로운 할 일 등록 작업을 한 후, TODO 섹션에 해당하는 SectionCollectionViewCell의 tableView에 아이템이 추가되어야 합니다. <b>SectionCollectionViewCell 와 SheetViewController간의 관계</b>를 직접적으로 연결하는 구조를 피하기 위해 ProjectManagerViewController로 간접적으로 거쳐갈 수 있는 구조로 해당 기능을 수행하는 방향에 대해 고민했습니다.<br><br>
- 해결 방안<br>
    1) 새로운 아이템 작성하기 위해 추가 버튼 탭할 때, <b>AddItemDelegate 프로토콜</b> 커스텀 작성
    2) 아이템에 대한 내용 작성 완료 후 SheetViewController의 modal 화면을 내릴 때, <b>updateItemHandler 메소드 (completionHandler)</b> 활용 
    
    | 타입명 | 수행 기능 |
    | - | - |
    |SectionCollectionViewCell| AddItemDelegate 프로토콜 준수 및 addNewCell 메소드 작성 |
    |ProjectManagerViewController|1) weak var delegate: AddItemDelegate <br> -> todoBoard를 대상으로 하는 SectionCollectionViewCell 설정<br> 2) SheetViewController의 updateItemHandler 호출 |
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

### SheetViewController의 일정 내용 수정 기능
<p align="center"><img src = "/image/ProjectManager_editmode.gif" width="500px"></p>
- 수정하고자 하는 일정 내용이 담긴 cell 을 tap 하여 수정한다.

### :thinking: 일정 추가 기능과 일정 수정 기능의 구현부를 공통적으로 추출할 수 있지 않을까?
- 고민점<br>
    해당 두 기능에 대해 <b>일정이 새로운 것이냐 / 일정이 이미 작성된 것이냐의 차이</b>를 지니고 있지만,<br> <b>SheetViewController에서 작성한 내용을 ProjectManagerViewController로 전달하는 flow가 동일하다</b>고 생각되었습니다. 이를 공통된 메소드로 추출할 수 있는 방법에 대해 고민해보았습니다.<br><br>
- 해결방안<br>
    ```swift
    // SheetViewController.swift

    var completionHandler: ((Item) -> Void)?

    func updateItemHandler(handler: @escaping (_ item: Item) -> Void) {
        completionHandler = handler
    }

     @IBAction private func tappedDoneButton(_ sender: Any) {
        guard let itemTitle = titleTextField.text,
              let itemDescription = descriptionTextView.text else {
            return
        }
        
        currentItem.title = itemTitle
        currentItem.description = itemDescription
        currentItem.timeStamp = Int(deadlineDatePicker.date.timeIntervalSince1970)
        
        if let completionHandler = completionHandler {
            completionHandler(currentItem)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    ```
    <b>SheetViewController</b> 의 프로퍼티 <b>completionHandler</b>의 재사용 방식을 택했습니다.<br>
    <b>tappedDoneButton</b> 메소드는 일정추가 혹은 일정수정 행동을 완료할 때 공통적으로 호출되기에 해당 과정에서 completionHandler로 설정하는 내용에 따라 다른 방식으로 동작합니다.<br><br>

    새로운 일정을 추가할 때, 
    ```swift
    //ProjectManagerViewController.swift
    
    private func createNewTodoItem() {
        var newItem = boardManager.todoBoard.createItem() //새로운 item 생성
        let presentedSheetViewController = presentSheetViewController(with: newItem, mode: Mode.editable)
        
        presentedSheetViewController.updateItemHandler { (currentItem) in
            newItem = currentItem
            newItem.progressStatus = ProgressStatus.todo.rawValue
            self.delegate = self.sectionCollectionView.cellForItem(at: [0,0]) as? SectionCollectionViewCell
            self.delegate?.addNewCell(with: newItem) // Todo Section에 해당하는 SectionCollectionViewCell 내의 TableView에 cell 추가
            
            let historyLog = HistoryLog.add(newItem.title)
            historyManager.historyContainer.append((historyLog, Date()))
            projectFileManager.updateFile()
        }
    }
    ```

    기존 일정을 수정할 때,
    ```swift
    //ProjectManagerViewController.swift

    private func updateItem(in boardTableViewCell: BoardTableViewCell, at index: Int, on board: Board) {
        let item = board.item(at: index) // 선택한 item
        let presentedSheetViewController = presentSheetViewController(with: item, mode: Mode.readOnly)
        
        presentedSheetViewController.updateItemHandler { (currentItem) in
            board.updateItem(at: index, with: currentItem)
            boardTableViewCell.updateUI(with: currentItem)
            projectFileManager.updateFile()
        }
    }
    ```
    <br>

    - 일정 추가 시에는 새로운 item을 대상으로 presentedSheetViewController (SheetViewController)의 updateItemHandler 내에서 생성 및 TODO 에 해당 item을 추가합니다.
    - 일정 수정 시에는 선택한 item을 대상으로 updateItemHandler 내에서 update 작업을 진행합니다.

### :thinking: 일정 수정 후, 일정을 나타내는 BoardTableViewCell의 layout이 업데이트 되지 않는다?
- 문제점
    BoardTableViewCell의 descriptionLabel의 numberOfLines = 3 으로 설정되어, 최대 3줄까지 내용이 보여야합니다. 하지만 cell이 최초 생성된 시점의 descriptionLabel의 text의 줄 갯수가 내용 업데이트에 맞게 조정되지 않습니다.
    ![ProjectMananger_boardtableviewcell](/image/ProjectManager_boardtableviewcell.png)<br><br>

- 원인
    기존 일정을 수정할 때,
    ```swift
    //ProjectManagerViewController.swift

    private func updateItem(in boardTableViewCell: BoardTableViewCell, at index: Int, on board: Board) {
        let item = board.item(at: index) // 선택한 item
        let presentedSheetViewController = presentSheetViewController(with: item, mode: Mode.readOnly)
        
        presentedSheetViewController.updateItemHandler { (currentItem) in
            board.updateItem(at: index, with: currentItem)
            boardTableViewCell.updateUI(with: currentItem)
            projectFileManager.updateFile()
        }
    }
    ```
    updateItemHandler의 클로저 내에서 내용 및 UI 업데이트 작업을 진행하지만, cell이 재사용되는 것이 아니기에 cell의 layout은 업데이트가 진행되지 않습니다. boardTableView의 해당 cell이 배치된 곳의 row가 reload되어야합니다. 
    <br>
- 해결방안
    새로운 일정을 추가할 때, updateItemHandler의 클로저 내에서 delegate를 통해 BoardTableView에 접근한 것과 마찬가지의 방식을 활용하여 개선해보았습니다.

    <br>프로토콜 AddItemDelegate -> BoardTableViewDelegate 로 네이밍 변경 <br> 
    
    | BoardTableViewDelegate | 요약 |
    |:-:|:-:|
    |func addNewCell(with item: Item) | 새로운 아이템 추가시, TableView에 cell 추가|
    func updateCell(at index: Int, with item: Item)| 아이템 수정 시, 해당 cell reload를 통한 업데이트 |

    ```swift
    //ProjectManagerViewController.swift

     private func updateItem(in boardTableViewCell: BoardTableViewCell, at index: Int, on board: Board) {
        let item = board.item(at: index)
        let presentedSheetViewController = presentSheetViewController(with: item, mode: Mode.readOnly)
        
        presentedSheetViewController.updateItemHandler { (currentItem) in
            switch board.title {
            case ProgressStatus.todo.rawValue:
                self.delegate = self.sectionCollectionView.cellForItem(at: [0,0]) as? SectionCollectionViewCell
            case ProgressStatus.doing.rawValue:
                self.delegate = self.sectionCollectionView.cellForItem(at: [0,1]) as? SectionCollectionViewCell
            case ProgressStatus.done.rawValue:
                self.delegate = self.sectionCollectionView.cellForItem(at: [0,2]) as? SectionCollectionViewCell
            default:
                break
            }

            self.delegate?.updateCell(at: index, with: currentItem)
            projectFileManager.updateFile()
        }
    }
    ```
    updateCell 내에 boardTableView.reloadRows() 를 진행하여 UI의 layout을 업데이트합니다.
    ```swift
    //SectionCollectionViewCell.swift
     func updateCell(at index: Int, with item: Item) {
        if let board = self.board {
            board.updateItem(at: index, with: item)
            boardTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    ```
    
---
## HistoryViewController
- UINavigationBar의 'history' 버튼:  할 일 생성/이동/삭제에 대한 기록을 저장한다.
    ![projectmanager_historyviewcontroller](/image/ProjectManager_historyviewcontroller.png)
        <p align="center"><img src = "/image/ProjectManager_historyviewcontroller.gif" width="500px"></p>
    HistoryViewController는 <b>UITableViewDataSource 프로토콜</b>을 준수합니다. 해당 ViewController의 <b>tableView는 히스토리 정보를 표현할 뿐,</b> tableView에 대한 어떠한 액션을 수행하는 것은 필요하지 않다 생각되어 UITableViewDelegate 프로토콜을 따로 준수하지 않습니다.

### :thinking: 히스토리 내역을 로컬디스크에 저장할까?
- 고민점<br>
    앱의 할일 리스트(todo, doing, done) 전체와 비교해보았을 때, 인앱 상황에서 변경되는 히스토리들은 앱이 켜져있는 동안의 히스토리만 보여주자고 팀원과 의논해보았습니다. 만약 히스토리 내역 또한 로컬디스크에 캐싱을 한다면 데이터의 축적으로 인한 cache 관리 작업도 지속적으로 해줘야하고, 사용자에겐 <b>'언제' '어떤 것'이 '어떻게 변경' 되었는지</b>에 대한 정보보단 <b>'현재 할 일의 상태'</b>를 보여주는 것이 적합하다고 생각했습니다.<br><br>
- 해결방안<br>
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

    #### 싱글톤패턴 사용 이유
    -  앱 전역에서 발생하는 아이템 생성/이동/삭제 관련 내용에 대해 전부 추적해야하기 위해 싱글톤 HistoryManager 내의 historyContainer에 해당 내역들을 담아 tableView로 표현했습니다.<br><br>

### :thinking: HistoryLog 출력시, description을 자동으로 출력할 순 없을까?
- 고민점<br>
```swift
enum HistoryLog {
    case add(String)
    case move(String, String, String)
    case delete(String, String)

    var description: String {
        switch self {
        case .add(let title):
            return "Added '\(title)'."
        case .move(let title, let before,  let after):
            return "Moved '\(title)' from \(before) to \(after)."
        case .delete(let title, let before):
            return "Removed '\(title)' from \(before)."
        }
    }
}
```

기존 HistoryLog 타입에 대해 위와 같이 작성하였는데, 코드리뷰를 통해
![ProjectManager_customconvertiblestring](/image/ProjectManager_customconvertiblestring.png)
와 같은 제안을 받아 <b>CustomConvertibleString</b>을 적용해보았습니다.

- 해결방안
```swift
enum HistoryLog: CustomStringConvertible { 이하 내용 동일 }
```
로 수정하니,<br>
기존 <b>HistoryLog의 인스턴스.description</b> 접근방식에서 
<b>HistoryLog의 인스턴스</b> 로 변경되었습니다.<br>

또한 HistoryManager의 <b>```var historyContainer = [(String, Date)]()```</b> 도 <b>```var historyContainer = [(HistoryLog, Date)]()```</b> 로 변경하여 더 직관적으로 표현 가능dml 효과와 description까지 접근하지 않아도 HistoryLog의 description 값을 가져올 수 있었습니다.

---
## Point 2) 로컬디스크캐시
[iOS File System 및 FileManager 블로그 포스팅 글 보러가기 (페이지 이동)](https://innieminnie.github.io/filesystem/filemanager/2021/05/30/FileManager.html)<br>
### ProjectFileManager(Singleton)
- <b>FileManager.default</b>를 활용하여 유저가 item 생성 / 수정 / 이동 / 삭제 등 작업을 할 때 해당 내역이 로컬디스크캐시에 업데이트 합니다.

```swift
private lazy var documentsURL: URL = {
    return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
}()
    
private lazy var fileURL: URL = {
    return documentsURL.appendingPathComponent("JSONFile.json")
}()

private init() {
    guard fileManager.fileExists(atPath: fileURL.path) else {
        fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        return
    }
}
```

- 유저가 파일의 내용에 대해 읽기/쓰기 작업이 가능해야하므로 <b>Documents</b> 디렉토리에 접근하도록 합니다.
- ProjectFileManager 생성시, 설정한 파일 위치에 파일의 존재를 확인하고 없으면 생성합니다.

```swift
func setItems() -> [Item] {
    do {
        let savedData = try Data(contentsOf: fileURL)
        if let savedItems = decoder.decodeJSONFile(data: savedData, type: [Item].self) {
            return savedItems
        }
    } catch {
        print("데이터 로딩 실패")
    }
    return []
}
    
func updateFile() {
    let data = try! JSONEncoder().encode(allItems)
    try? data.write(to: fileURL)
}
```
|메서드명|설명|
|:-:|:-:|
|func setItems() -> [Item]|앱이 실행된 이후 파일 읽기 및 파일의 데이터를 JSONDecoder를 통해 [Item]으로 파싱합니다.|
|func updateFile()|item의 생성/수정/삭제/이동에 따라 파일내용도 업데이트 합니다.|


---
## Point 3) 지역화
- [지역화 블로그 포스팅 글 보러가기 (페이지 이동)](https://innieminnie.github.io/localization/internalization/2021/06/02/Localization.html)

해당 프로젝트에서 보여지는 텍스트 (유저가 작성하는 텍스트 제외) 에 대해 한국과 프랑스를 대상으로 지역화를 적용해보았습니다.

### Main.strings 와 Localizable.strings
스토리보드에서 직접 접근이 가능한 UIComponents에 대해선 <b>Main.strings</b> 파일에서 작성을 해주었고, 액션에 따라 내용이 달라지거나 코드로 접근해야만 하는 경우에 대해선 <b>Localizable.strings</b> 에 작성했습니다.

<b>Localizable.strings</b>
![ProjectManager_localization](/image/ProjectManager_localization.png)

<b>HistoryLog</b>는 액션에 따라 내용 또한 달라지기에 <b>%@</b> 서식문자를 활용하여 지역화를 적용했습니다.

```swift
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

```