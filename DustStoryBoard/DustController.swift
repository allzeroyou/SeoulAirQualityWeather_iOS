//
//  DustController.swift
//  DustStoryBoard
//
//  Created by dheum on 2020/07/13.
//  Copyright © 2020 dheum. All rights reserved.
//

import UIKit
import Alamofire

class DustController: UIViewController {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var dustTable: UITableView!
    var airArray: [Air] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getDusts() // getDusts: AlarmoFire를 통해 통신구현
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.airArray.removeAll()
        self.getDusts()
        
    }
    
    func getDusts() -> Void {
        let url = "http://openapi.seoul.go.kr:8088/5963636d767333353639476875796d/json/" +
                        "ListAirQualityByDistrictService/1/25/"; // 다영 url 변경

        AF.request(url).responseString(encoding: .utf8) { response in
            switch response.result {
            case .success(let value):
                self.parseJson(json: value)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func parseJson(json: String) -> Void { // json parse
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8) // utf로 인코딩, data는 옵셔널
        // 옵셔널 바인딩
        if let data = data, let obj = try? decoder.decode(Data.self, from: data) { // decode: nil반환 가능성 있음 -> try?로 처리
            self.airArray = obj.ListAirQualityByDistrictService.row // airArray: field로 정의(코드 내 어디서나 사용 가능)
        }
        self.dustTable.reloadData()
        if airArray.count != 0 {
            var str = String(airArray[0].MSRDATE.dropLast(2)) // 날짜 가져온다. 뒤에 가져오는 '분'에 해당하는 2개 문자는 제거한다.
            str = str + " 기준"
            self.dateLabel.text = str
        }
    }
}

extension DustController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.airArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "DustCell", for: indexPath)
        
        if let label = cell.contentView.viewWithTag(1) as? UILabel {
            label.text = self.airArray[indexPath.row].MSRSTENAME
        }
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = self.airArray[indexPath.row].PM10
        }
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            if self.airArray[indexPath.row].GRADE != "" {
                label.text = self.airArray[indexPath.row].GRADE
            } else {
                label.text = "N/A"
            }
        }
        return cell
    }
}
