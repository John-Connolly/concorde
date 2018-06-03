//
//  Try.swift
//  concord
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation

enum Try<T> {
    case Successful(T)
    case Failure(Error)
    init(_ f: () throws -> T) {
        do {
            self = .Successful(try f())
        } catch {
            self = .Failure(error)
        }
    }

    func map<U>(_ f: (T) -> U) -> Try<U> {
        switch self {
        case .Successful(let value): return .Successful(f(value))
        case .Failure(let error): return .Failure(error)
        }
    }
    
    func flatMap<U>(_ f: (T) -> Try<U>) -> Try<U> {
        switch self {
        case .Successful(let value): return f(value)
        case .Failure(let error): return .Failure(error)
        }
    }

    func onError(_ f: (Error) -> ()) {
        switch self {
        case .Successful: return
        case .Failure(let error): return f(error)
        }
    }
}
