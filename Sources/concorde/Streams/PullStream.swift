//
//  PullStream.swift
//  concorde
//
//  Created by John Connolly on 2018-03-30.
//  Copyright © 2018 John Connolly. All rights reserved.
//

import Foundation

enum Input<Event> {
    case input(Event)
    case done
}

protocol PullStream: class {
    associatedtype InputValue
    var upstream: ConnectionContext? { get set }
    func input(_ value: Input<InputValue>)
}

final class AnyPullStream<T>: PullStream {

    typealias InputValue = T
    weak var upstream: ConnectionContext?
    private let onInput: (Input<T>) -> ()

    init<S: PullStream>(_ wrapped: S) where S.InputValue == T {
        onInput = wrapped.input
    }

    func input(_ value: Input<T>) {
        onInput(value)
    }
   
}
