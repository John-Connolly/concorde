//
//  ConnectionContext.swift
//  concorde
//
//  Created by John Connolly on 2018-04-05.
//  Copyright © 2018 John Connolly. All rights reserved.
//

import Foundation

protocol ConnectionContext: class {
    func connection(_ event: ConnectionEvent)
}

extension ConnectionContext {

    func request() {
        connection(.request)
    }

    func cancel() {
        connection(.cancel)
    }

    func error(with error: Error) {
        connection(.error(error))
    }

    func connect<S: ConnectionContext>(to stream: S) {
        
    }
}

enum ConnectionEvent {
    case request
    case cancel
    case error(Error)
}

