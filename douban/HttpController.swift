
import UIKit
import Alamofire
import SwiftyJSON

class HttpController : NSObject{

    var delegate:HttpProtocol?
    
    func onSearch(url:String){
        Alamofire.request(Method.GET, url).responseJSON{ res in
            
            let myJson = JSON(data: res.2.data!)
            
            print("myJSON\(myJson)")
            
            self.delegate?.didReciveveResults(myJson)
            
        }
    }
}

protocol HttpProtocol{

    func didReciveveResults(results:JSON)

}