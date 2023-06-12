import UIKit
import Alamofire

class DetailController: UIViewController {
    @IBOutlet weak var carbonLabel: UILabel!
    @IBOutlet weak var nitrogenLabel: UILabel!
    @IBOutlet weak var ozoneLabel: UILabel!
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var pm25Label: UILabel!
    @IBOutlet weak var weatherTextView: UITextView!
    
    var airDetail: Air?
    var guDetail = "" // 지자체
    var navigationItemGu = "" // 연산을 위해 필요한 변수
    var dataStr = "" // 원본 날짜 문자열
    var hourStr = "" // 현재 시간
    var todayStr = "" // 오늘 날짜
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItemGu = guDetail + " 세부정보"
        navigationItem.title = navigationItemGu
        
//        carbonLabel.text = "일산화탄소: " + airDetail?.CARBON
        carbonLabel.text = "일산화탄소: " + (airDetail?.CARBON ?? "")
        nitrogenLabel.text = "이산화질소: " + (airDetail?.NITROGEN ?? "")
        ozoneLabel.text = "오존: " + (airDetail?.OZONE ?? "")
        pm10Label.text = "미세먼지: " + (airDetail?.PM10 ?? "")
        pm25Label.text = "초미세먼지: " + (airDetail?.PM25 ?? "")
        
        self.getWeather()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getWeather() {
        let url = "https://apis.data.go.kr/1360000/MidFcstInfoService/getMidFcst?serviceKey=3JjM4ywSiOm68eVL9D4idMkcUiZ5GKlKWAl1H44IotvQ5ypCVmj%2ByLqMeSXwP4c3ckD0bo7iCyN8JkOwgtkINg%3D%3D&pageNo=1&numOfRows=10&dataType=json&stnId=109&tmFc="
        
        let todayStr = dataStr.prefix(8) // 날짜
        let hourStr = dataStr.suffix(2) // 시간
        
        print(hourStr)
        print(todayStr)
        
        if let hour = Int(hourStr), hour > 6 {
            let urlWithTime = url + todayStr + "0600"
            
            AF.request(urlWithTime).responseString(encoding: .utf8) { response in
                switch response.result {
                case .success(let value):
                    if let json = value.data(using: .utf8),
                       let jsonObject = try? JSONSerialization.jsonObject(with: json, options: []),
                       let jsonDict = jsonObject as? [String: Any],
                       let response = jsonDict["response"] as? [String: Any],
                       let body = response["body"] as? [String: Any],
                       let items = body["items"] as? [String: Any],
                       let itemArray = items["item"] as? [[String: Any]],
                       let item = itemArray.first,
                       let weatherDescription = item["wfSv"] as? String {
                        self.updateWeatherTextView(weatherDescription: weatherDescription)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            weatherTextView.text = "N/A"
        }
    }
    
    func updateWeatherTextView(weatherDescription: String) {
        weatherTextView.text = weatherDescription
    }
}
