//
//  Flip.swift
//  concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation

public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in { a in f(a)(b) } }
}
