//
//  Stations.swift
//  create-level-starter-app
//
//  Created by Jason Ruan on 7/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

struct Station: Codable, Equatable {
    let id: String
    let name: String
}

struct DataWrapper: Codable {
    let data: [ArrivalTimes]
}

struct ArrivalTimes: Codable {
    let N: [Route_Time]
    let S: [Route_Time]
    let id: String
    let last_update: String?
    let location: [Double]
    let name: String
    let routes: [String]
    let stops: [String : [Double]]
}

struct Route_Time: Codable {
    let route: String
    let time: String
}
