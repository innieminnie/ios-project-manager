import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    let urlString = "https://zdo.herokuapp.com/memos"
    
    func fetch() {
        AF.request(urlString).validate().responseData { response in
            switch response.result {
            case .success:
                print("Success")
            case .failure(let e):
                print(e)
            }
        }
        
        //GET Memos
        AF.request(urlString).responseJSON { (response) in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = DecodeJSON().decodeJSONFile(data: jsonData, type: [Item].self)
                } catch(let err) {
                    print(err.localizedDescription)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func create() {
        
    }
    
    func update() {
        
    }
    
    func delete() {
        
    }
}

let networkManager = NetworkManager.shared
