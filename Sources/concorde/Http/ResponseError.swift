//
//  ResponseError.swift
//  concorde
//
//  Created by John Connolly on 2018-11-14.
//

import Foundation

public enum ResponseError: Error {
    case internalServerError
    case abort
    case custom(Response)
}
