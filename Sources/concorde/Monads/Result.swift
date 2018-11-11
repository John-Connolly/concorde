//
//  Result.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
    
    init(_ f: () throws -> T) {
        do {
            self = .success(try f())
        } catch {
            self = .failure(error)
        }
    }

    func map<U>(_ f: (T) -> U) -> Result<U> {
        switch self {
        case .success(let value): return .success(f(value))
        case .failure(let error): return .failure(error)
        }
    }
    
    func flatMap<U>(_ f: (T) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let value): return f(value)
        case .failure(let error): return .failure(error)
        }
    }

    func onError(_ f: (Error) -> ()) {
        switch self {
        case .success: return
        case .failure(let error): return f(error)
        }
    }
}
