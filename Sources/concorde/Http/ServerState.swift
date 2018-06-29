//
//  ServerState.swift
//  concorde
//
//  Created by John Connolly on 2018-06-28.
//

import Foundation
import NIOHTTP1

enum ServerState {
    case idle
    case waitingForRequestBody(HTTPRequestHead)
    case sendingResponse


    mutating func recievedGetRequest() {
        self = .sendingResponse
    }

    mutating func receivedHead(_ head: HTTPRequestHead) {
        self = .waitingForRequestBody(head)
    }

    mutating func done() {
        self = .idle
    }
}
