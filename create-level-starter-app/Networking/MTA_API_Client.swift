//
//  MTA_API_Client.swift
//  create-level-starter-app
//
//  Created by Jason Ruan on 7/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

class MTA_API_Client {
    private init() {}
    static let manager = MTA_API_Client()
    
    func getStations(url: URL, completionHandler: @escaping (Result<[Station], AppError>) -> () ) {
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
            switch result {
                case .failure(let error):
                    print(error)
                    completionHandler(.failure(error))
                case .success(let data):
                    do {
                        let dict = try JSONDecoder().decode([String : Station].self, from: data)
                        var stations = [Station]()
                        for val in dict.values {
                            stations.append(val)
                        }
                        completionHandler(.success(stations))
                    } catch {
                        completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                }
            }
        }
    }
    
    func getArrivalTimesForStation(withID id: String, completionHandler: @escaping (Result<ArrivalTimes, AppError>) -> () ) {
        guard let url = URL(string: "https://api.wheresthefuckingtrain.com/by-id/\(id)") else {
            completionHandler(.failure(.badURL))
            return
        }
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
            switch result {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let data):
                    do {
                        guard let arrivalTimes = try JSONDecoder().decode(DataWrapper.self, from: data).data.first else {
                            completionHandler(.failure(.invalidJSONResponse))
                            return
                        }
                        completionHandler(.success(arrivalTimes))
                    }   catch {
                        completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                }
            }
        }
    }
    
}
