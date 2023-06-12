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
    @IBOutlet var dateLabel: UILabel! // 날짜
    @IBOutlet var dustTable: UITableView! // table
    var guName: [String] = [] // 지자체
    
    @IBOutlet weak var maxMinLabel: UILabel!
    var airArray: [Air] = []
    var maxMinArray: [Int] = [] // 최대최소 미세먼지
    
var airDetailArray: [Air] = [] // 대기질 세부정보
    var hourStr = "" // 기상 예보 정보를 위한 시간정보
    var dateStr = "" // 기상 예보 정보를 위한 날짜정보
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getDusts() // getDusts: AlarmoFire를 통해 통신구현
        dustTable.delegate = self
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.airArray.removeAll()
        self.getDusts() // 새로고침
    }
    
    func getDusts() -> Void {
        let url = "http://openapi.seoul.go.kr:8088/5963636d767333353639476875796d/json/ListAirQualityByDistrictService/1/25/"; // 다영 url 변경
    // http://openapi.seoul.go.kr:8088/5963636d767333353639476875796d/json/ListAirQualityByDistrictService/1/25
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
            let str = String(airArray[0].MSRDATE.dropLast(2)) // 날짜 가져온다. 뒤에 가져오는 '분'에 해당하는 2개 문자는 제거한다.
            
            //todayDate = String(airArray[0].MSRDATE) // 현재 시간
            
            let dateStr = str.prefix(8)  // 시간을 제거한 날짜
            let hourStr = str.suffix(2)  // 시간
            
            let sub_str = dateStr + "일 "+hourStr+"시 기준"
            self.dateLabel.text = sub_str // label에 값 대입
        }
        //print(airDetailArray)
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
            label.text = self.airArray[indexPath.row].MSRSTENAME // 지자체
            if let text = label.text { // detail로 지자체 title 넘김
                guName.append(text)
            }
        }
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = self.airArray[indexPath.row].PM10
        }
        
        let miseStr = self.airArray[indexPath.row].PM10
        // 미세먼지 최고, 최저
        
        if let intValue = Int(miseStr ?? "") {
            maxMinArray.append(intValue)
        }
        
        // grade 문자열이 ""인거 같은데.. 왜지? -> 수정 필요
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            if self.airArray[indexPath.row].GRADE != "" {
                label.text = self.airArray[indexPath.row].GRADE
            } else {
                label.text = "N/A"
            }
        }
        // maxMinArray에서 최대, 최소값을 maxMinLabel에 대입
        let highestValue = maxMinArray.max()
        let lowestValue = maxMinArray.min()
        
        let highestString = highestValue != nil ? "\(highestValue!)" : "N/A"
        let lowestString = lowestValue != nil ? "\(lowestValue!)" : "N/A"
        
        maxMinLabel.text = "최고: \(highestString) / 최저: \(lowestString)"
        
        
        return cell
    }//tableView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DetailController , let indexPath = dustTable.indexPathForSelectedRow{
            let index = indexPath.row
            dest.guDetail = guName[index] // 구
            let selectedAir = airArray[indexPath.row]
            dest.airDetail = selectedAir // 대기질 세부정보
            
            let originalDate = String(selectedAir.MSRDATE.dropLast(2))
            dest.dataStr = originalDate
            print(originalDate)

        }
    }
    
    
    
    
    
}
