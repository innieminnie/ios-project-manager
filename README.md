# 프로젝트매니저 칸반보드 📝

> <br> 할 일 일정에 대해 <b>TODO, DOING,DONE</b> 으로 나눈 칸반보드로 관리합니다.<br><br>


---
## 주요 구현 사항
### point1) UICollectionViewCell 내에 UITableView 배치 방식으로 UI구성
![projectmanager_projectmanagerviewcontroller](/image/ProjectManager_projectmanagerviewcontroller.png)

1. 3개 각각의 UITableView ( todoTableView, doingTableView, doneTableView) 를 하나의 View 내부에 배치하기

1. UICollectionViewCell 내에 UITableView 및 UITableViewCell 을 배치하기

두 방식에 대한 고민 후, <b>2번 방식</b>을 선정했습니다.

> <b> 1) ProjectManagerViewController 
    2) SectionCollectionViewCell
    3) boardTableView </b><br>    
    각각의 역할을 분리시키는 데 초점을 맞추기로 했습니다. 
    UI구성의 복잡도는 높아졌지만,<br> 
    <b> - 하나의 cell에서 하나의 boardTableView만 관리합니다.
    - boardTableView는 SectionCollectionView내 board의 item만 대상으로 하여 tableViewCell에 표시합니다.</b> <br><br>

- <b> 1) ProjectManagerViewController</b> 
    UINavigationBar의 '+' 혹은 'history', 하단의 undo/redo 버튼에 대한 액션 수행<br><br>
    
    - UINavigationBar의 '+' 버튼: 새로운 할 일을 작성한다.

        ![projectmanager_sheetviewcontroller](/image/ProjectManager_sheetviewcontroller.png)
        ![projectmanager_sheetviewcontroller_gif](/image/ProjectManager_sheetviewcontroller.gif)

    - UINavigationBar의 'history' 버튼:  할 일 생성/이동/삭제에 대한 기록을 저장한다.
        ![projectmanager_historyviewcontroller](/image/ProjectManager_historyviewcontroller.png)
   
        ![projectmanager_historyviewcontroller_gif](/image/ProjectManager_historyviewcontroller.gif)

    - 화면 하단의 'Undo / Redo ' 버튼: 수행작업에 대한 되돌리기/ 다시하기 기능을 수행한다.

        ![projectmanager_undoredo_gif](/image/ProjectManager_undoredo.gif)
    <br><br>

- <b> 2) SectionCollectionViewCell </b> 
        Todo / Doing / Done 단위의 Board 관리<br><br>
    
    ![projectmanager_sectioncollectionviewcell](/image/ProjectManager_sectioncollectionviewcell.png)


    - <b> 3) boardTableView</b> 
    각 Board 내의 Item 관리<br><br>

    <b>SectionCollectionViewCell (UICollectionViewCell)</b> 은 <b>하나의 boardTableView (UITableView) </b> 를 가지고 있는 구조를 통해, UITableViewCell에 표현될 Model을 

### point2) 로컬디스크캐시
### "히스토리 내역을 굳이 로컬디스크에 저장해놓을 필요가 있을까?"

- 고민에 대한 노력
    - 앱의 할일 리스트들은 로컬디스크에 저장해놓아야하지만 인앱 상황에서 변경되는 히스토리들은 굳이 로컬디스크에 캐싱하여 저장할 필요가 없이 앱이 켜져있는 동안의 히스토리만 보여주면 된다고 생각한다. 만약 로컬로 저장해놓는다면 계속 데이터가 쌓일것이고 사용자 입장에서도 불편할것같다. 그래서 HistoryManager라는 싱글톤 타입을 통해 앱이 켜져있을때만 historyContainer로 구현한 String,Date 자료구조에 담고 테이블뷰에 데이터를 나타낼 수 있도록하였다.

    ```swift
    class HistoryManager {
      static let shared = HistoryManager()
      var historyContainer = [(HistoryLog, Date)]()
    }
    let historyManager = HistoryManager.shared
    ```

    - 그러다 또 생각해본점이 히스트리 내역을 코어데이터를 사용하여 구현을 하면 심플하지 않을까 생각했다.
    결국 코어데이터도 디바이스에 저장하는것으로 로컬디스크와 차이는 디바이스에서만 저장됨으로 만약 다른 디바이스로 작동을 시킨다면 히스토리 정보가 남아있지 않게 되었다. 굳이 둘중에 따지자면 코어데이터 보다는 로컬디스크에 저장하는 방식이 더 맞다고는 느껴졌다.

---
## 트러블슈팅
### "지역화"

- 문제점
    - 지역화가 부분적으로만 이루어진 문제가 발생
- 원인
    - 코드에서 구현한 텍스트가 있고 스토리보드에서 구현한 텍스트가 있다. 지역화를 진행할때는 두 부분을 각 다른 파일에서 지역화를 시켜주도록 해야하는데, 코드 지역화 파일에만 지역화 내용을 추가해줘서 나타나는 문제

    ```
    "Project Manager" = "Chef de projet";
    "Cancel" = "Annuler";
    "Edit" = "mise en forme";

    "TODO"  = "Plan";
    "DOING" = "En cours";
    "DONE"  =  "Terminé";

    "Added '%@'." = "'%@'Ajouter.";
    "Moved '%@' from %@ to %@." = "'%@'un %@dans %@to Nous avons bougé.";
    "Removed '%@' from %@." = "'%@'un supprimer.";

    ```

    ![https://user-images.githubusercontent.com/72292617/116360760-32938e80-a83b-11eb-830b-17f23baaf126.png](https://user-images.githubusercontent.com/72292617/116360760-32938e80-a83b-11eb-830b-17f23baaf126.png)

- 해결방안
    - 코드의 변수로 선언된 부분은 위와 같이 Localizable.strings 파일을 이용해 지역화를 시켜주고 스토리보드에서 얹은 요소에 대한 지역화는 아래와 같이 Main.string 스토리보드 지역화 파일에 별도 작성을 해주어야한다.

    ![https://user-images.githubusercontent.com/72292617/116360915-61116980-a83b-11eb-8854-709c865598c2.png](https://user-images.githubusercontent.com/72292617/116360915-61116980-a83b-11eb-8854-709c865598c2.png)

    ```
    /* Class = "UIBarButtonItem"; title = "Done"; ObjectID = "1Iz-ek-qSt"; */
    "1Iz-ek-qSt.title" = "Terminé";

    /* Class = "UINavigationItem"; title = "TODO"; ObjectID = "8tB-ho-ekQ"; */
    "8tB-ho-ekQ.title" = "Plan";

    /* Class = "UINavigationItem"; title = "Title"; ObjectID = "BsE-ch-KEa"; */
    "BsE-ch-KEa.title" = "Titre";

    /* Class = "UITextField"; placeholder = "Title"; ObjectID = "Ne9-CO-XbT"; */
    "Ne9-CO-XbT.placeholder" = "Titre";

    /* Class = "UILabel"; text = "Label"; ObjectID = "VLk-en-wR1"; */
    "VLk-en-wR1.text" = "étiquette";

    /* Class = "UILabel"; text = "Title"; ObjectID = "eqg-sO-J0R"; */
    "eqg-sO-J0R.text" = "Titre";

    /* Class = "UIBarButtonItem"; title = "Cancel"; ObjectID = "keU-l8-vF1"; */
    "keU-l8-vF1.title" = "annuler";
    ```

    해당 스토리보드 상 객체의 오브젝트 ID를 캐치하여 추가하는 방향으로 수정해보았다.

    ![https://user-images.githubusercontent.com/72292617/116361089-8aca9080-a83b-11eb-88b8-81d5683f71c9.png](https://user-images.githubusercontent.com/72292617/116361089-8aca9080-a83b-11eb-88b8-81d5683f71c9.png)

### "런치스크린 지역화"

- 문제점
    - 런치스크린에서도 텍스트를 넣고 지역화를 해주고 싶었는데 런치 스크린은 지역화가 되지 않는 문제
- 원인
    - HIG에서 답을 찾았는데 런치 스크린은 정적임으로 표시되는 텍스트를 현지화하지 않아 텍스트를 포함하지말라고 친절하게 나와있다. iOS 앱은 "로드 중 메시지"를 표시하지 않아야한다. 이걸 토대로 생각해보았을때 런치 스크린도 설정의 일부인데 앱의 지역화 텍스트를 빌드하고 설정을 통해 잡아와야하는데 런치스크린도 그런 데이터를 설정하는 단계라 언제 끝날지 몰라 지역화를 지원하지 않는다고 생각하고 결론지었다.
- 해결방안
    - 지원되지 않는 런치 스크린에 대한 지역화 및 텍스트를 제거하였다.

### "유저 노티피케이션 해제"

- 문제점
    - 메모가 삭제 및 완료 되었는데도 유저노피티케이션 알림이 오는 문제
- 원인
    - 노티피케이션을 생성하고 호출이되었다면 메모가 삭제 및 완료되는 시점에서는 이미 호출된 노티피케이션 알림을 해제하는 기능도 구현해야하는데 이 부분이 구현되지 않아 발생하였다.
- 해결방안
    - 메모가 삭제되면 해당 Notification의 Identifier를 가지고 해제해주도록 구현 수정하였다.

    ```swift
        mutating func updateProgressStatus(with progressStatus: String) {
          self.progressStatus = progressStatus
          if self.progressStatus == ProgressStatus.done.rawValue {
              notificationManager.removeNofitication(name: "\(self.dueDate)")
          } else {
              notificationManager.configureNotification(name: "\(self.dueDate)", date: self.dueDate)
          }
      }
    ```

    위와 같이 상태를 체크할때 Done 영역에 있어도 노티피케이션의 알림을 해제해준다.

### "로그 객체를 출력할때 자동으로 description이 출력되게 할 순 없을까?"

```swift
enum HistoryLog {
   case add(String)
   case move(String, String, String)
   case delete(String)

   var description: String {
       switch self {
       case .add(let title):
           return "Added \(title)"
       case .move(let title, let before,  let after):
           return "Moved \(title) from \(before) to \(after)"
       case .delete(let title):
           return "Deleted \(title)"
       }
   }
 }
```

- 고민에 대한 노력
    - 매번 description 출력을 위해 한단계 거치는것이 불편해서 찾아보았는데 CustomConvertibleString 프로토콜에서 해당 기능을 해준다. 이 부분을 토대로 개선해보았다.

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





-- 구현사항
- 지역화를 구현해 한국 / 프랑스 / 영어로 언어가 나타나도록 구현하였다.
- Todo/Doing/Done의 상태를 이용하여 각 해당 테이블 셀에 맞게 구현하였다.
- 전체적인 뷰를 컬렉션 뷰 안에 테이블 뷰 3개가 들어가도록 구현하였다.
- 파일 매니저를 학습하고 구현하여 로컬에서 해당 앱의 JSON 데이터 정보를 저장하도록 구현하였다.
- 노티피케이션을 학습하고 구현하여 각 시간에 맞게 푸시 알림이 가도록 구현하였다.
- 각 모드 및 상태를 Enum 타입으로 정의하고 폴더화 시켰다.
- 팝오버를 학습하고 이력을 팝오버 할 수 있도록 구현하였다.
- 로컬에서 네트워크 연결 상태에 대해 학습하고 각 상태에 대한 대응을 구현하였다.
    - 네트워크 상태에 따라 레이블 변화를 디스패치큐로 메인 스레드에서 바로 보이도록 비동기 처리를 하였다.
    - 네트워크 상태 감지는 NWPathMonitor 메서드를 가지고 백그라운드에서 모니터링 될 수 있도록 구현하였다.
- 뷰를 코드 및 스토리보드로 구현하고 xib 파일 구현을 통해 셀을 구현하였다.
- 영역 별 드래그 앤 드롭 기능을 학습하고 구현하였다.
- 노티피케이션 센터를 이용해 메서드 상태 변화를 관찰하고 기능 동작하도록 구현하였다.
- Undo & Redo를 통해 되돌리기 및 되돌리기 취소 기능을 구현하였다.
- 날짜 형식을 알맞게 포맷팅하여 변환하였다.

-- 트러블슈팅
## **🤔 고민한 점**


### "Mode case 네이밍에 관해 더 좋은 네이밍은 없을까?"

```swift
enum Mode {
  case editable
  case uneditable
...
```

- 고민에 대한 노력
    - '수정 할 수 없는' 이라는 뜻으로 네이밍하였는데, 수정할 수없는것이 읽기전용이라는 네이밍이 더 적합하여 readOnly로 개선하였다.

### "dueDate와 date 의미가 모호한데 개선해볼 수 없을까?"

```swift
var dueDate: Int
var date: Date {
```

- 고민에 대한 노력
    - 처음 dueDate를 systemTime으로 변경하였는데 명확하지 않게 느껴졌다. systemTime으로 고치니 date의 의미가 불명확해졌다. 그래서 아래와 같이 수정을 거쳤다.
    - dueDate는 아이템에 대한 데이터를 받아오는 시스템 시간임으로 timeStamp로 date는 받아온 timeStamp에 대한 날짜 표시로 변환하는것임으로 dueDate로 개선하였다.

    ```swift
    var timeStamp: Int
    var dueDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(timeStamp))
    }
    ```

### "onvertDateToString 메소드가 extension으로 선언되었을 때와 직접 선언한 객체에서 선언되었을 때의 장단점은 무엇일까?"

```swift
extension DateFormatter {
  func convertDateToString(date: Date) -> String {
      let currentLocale = Locale.current.collatorIdentifier ?? "ko_KR"let formatter = DateFormatter()

       formatter.locale = Locale(identifier: currentLocale)
       formatter.dateFormat = "yyyy.MM.dd"return formatter.string(from: date)
  }
}
```

- 고민에 대한 노력
    - DateFormatter를 extension하여 해당 메서드를 구현하게되면 추후 다른 클래스나 객체에서 해당 메서드를 호출할때 Item 타입의 인스턴스를 만들어 접근하지 않아도 된다. 클래스 내부에 메서드로 만들게되면 해당 메서드를 사용할때 객체 인스턴스를 만들고 호출해야함으로 인스턴스를 만드는 메모리가 잡혀 extension으로 접근하는것이 메모리적 측면에서 더 효율적이다.

### "함수 안에 함수를 넣어 선언하는 상황과 이유는 무엇일까?"

```swift
func updateUI(with item: Item) {
      self.titleLabel.text = item.title
      self.descriptionLabel.text = item.description
      self.dueDateLabel.text = item.dateToString
      
      func configureDueDateLabelColor() {
          let currentTimeInterval = Date().timeIntervalSince1970
          let currentDateToInt = Int(currentTimeInterval)
          
          if currentDateToInt > item.timeStamp {
              self.dueDateLabel.textColor = .red
          } else {
              self.dueDateLabel.textColor = .black
          }
      }
      
      configureDueDateLabelColor()
  }
```

- 고민에 대한 노력
    - 해당 메서드는 updateUI 메서드가 호출되는 경우에만 호출된다. 그럼으로 항상 내부적으로 호출되어 dueDate의 상태(기간만료 되었는지)를 체크해준다는걸 보여줄 수 있다.


### "UserNotification 설정 시 badge는 무슨 역할을 할까?"

- 고민에 대한 노력
    - 실제로 감이오지 않아 구현해보고 테스트를 해봤는데 뱃지는 그냥 앱 아이콘에 표시되는 아래와 같은 수이다. 1로 설정해놓은 1이 10으로 설정해놓으면 10이 뜬다. 앱에서 사용자에게 몇개의 알림이 있다고 보내주고 싶을때 설정하면 좋을것 같다.

    ![https://user-images.githubusercontent.com/72292617/116362745-59eb5b00-a83d-11eb-96b0-bed29202ef9d.png](https://user-images.githubusercontent.com/72292617/116362745-59eb5b00-a83d-11eb-96b0-bed29202ef9d.png)

### "App의 NotificationDelegate를 어디서 다뤄주면 좋을까?"

- 고민에 대한 노력
    - 처음 VC에서 해당 노티피를 구성하고 호출하니까 막연하게 Extension하여 구성하였다. 그런데 생각해보면 만약 App이 닫혀있고 푸시 알림을 통해 다시 앱의 뷰가 로드된다면 뷰가 정상적으로 로드되지 않거나 지연될 때 해당 기능의 역할을 제대로 수행하지 못한다. 그래서 App의 전반적인 부분의 역할을 해주는 AppDelegate에서 다뤄주는것이 더 적합하다고 생각한다.

    ```swift
    class AppDelegate: UIResponder, UIApplicationDelegate {
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          // Override point for customization after application launch.
          notificationManager.requestNotificationAuthorization()
          return true
      }
    ```

    - 실제로 리팩토링 하기 전 NotificationDelegate를 메인 VC에서 설정해주었는데 앱이 실행되고 뷰가 올라오는 속도가 느릴때 간혹 알림 허용 인증이 나타나지 않았다.

## **📱 동작화면**

![https://user-images.githubusercontent.com/72292617/116354491-784c5900-a833-11eb-8bcd-99899bfeb05d.gif](https://user-images.githubusercontent.com/72292617/116354491-784c5900-a833-11eb-8bcd-99899bfeb05d.gif)