//
//  AppError.swift
//  create-level-starter-app
//
//  Created by Jason Ruan on 7/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

enum AppError: Error {
    case unauthenticated
    case invalidJSONResponse
    case couldNotParseJSON(rawError: Error)
    case noInternetConnection
    case badURL
    case badStatusCode
    case noDataReceived
    case notAnImage
    case other(rawError: Error)
}
