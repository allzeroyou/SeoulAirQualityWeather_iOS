import UIKit
import Alamofire

class LoginController: UIViewController {
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var passwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: Any) {
        guard let id = idField.text, !id.isEmpty,
              let passwd = passwdField.text, !passwd.isEmpty else {
            displayWrongAlert()
            return
        }
        
        let urlString = "http://203.252.213.36:8080/FinalProject/loginPro.jsp?id=\(id)&passwd=\(passwd)"
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        AF.request(encodedUrlString).responseString(encoding: .utf8) { response in
            switch response.result {
            case .success(let str):
                let trimmedStr = str.trimmingCharacters(in: .whitespaces)
                
                if trimmedStr.contains("0") || trimmedStr.contains("-1") {
                    self.displayWrongAlert()
                } else {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    if let dustController = storyBoard.instantiateViewController(withIdentifier: "Dust") as? DustController {
                        self.navigationController?.pushViewController(dustController, animated: true)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func displayWrongAlert() {
        let alertController = UIAlertController(title: "로그인 실패", message: "다시 입력하세요~", preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        passwdField.text = "" // 비밀번호 지운다
        
        present(alertController, animated: true, completion: nil)
    }
}
