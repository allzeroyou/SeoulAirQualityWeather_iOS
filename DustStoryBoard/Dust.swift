//
//  Dust.swift
//  DustSwiftUI
//
//  Created by dheum on 2020/07/09.
//  Copyright © 2020 dheum. All rights reserved.
//

import Foundation

struct Data : Codable {
    let ListAirQualityByDistrictService : DustData
}

struct DustData : Codable {
    let row : [Air]
}

struct Air : Codable {
    let MSRDATE : String
    let MSRSTENAME : String
    let PM10 : String
    let GRADE : String
}
