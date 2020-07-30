//
//  NetworkManager.swift
//  create-level-starter-app
//
//  Created by Jason Ruan on 7/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get
    case post
}

class NetworkHelper {
    
    // MARK: - Static Properties
    
    static let manager = NetworkHelper()
    
    // MARK: - Instance Methods
    func performDataTask(withUrl url: URL,
                         andHTTPBody body: Data? = nil,
                         andMethod httpMethod: HTTPMethod,
                         completionHandler: @escaping ((Result<Data, AppError>) -> ())) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data else {
                    completionHandler(.failure(.noDataReceived))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200...299) ~= response.statusCode else {
                    completionHandler(.failure(.badStatusCode))
                    return
                }
                
                if let error = error {
                    let error = error as NSError
                    if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
                        completionHandler(.failure(.noInternetConnection))
                        return
                    } else {
                        completionHandler(.failure(.other(rawError: error)))
                        return
                    }
                }
                completionHandler(.success(data))
            }
            }.resume()
    }
    
    // MARK: - Private Properties and Initializers
    
    private let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    
    private init() {}
}
