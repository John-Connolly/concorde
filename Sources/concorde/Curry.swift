//
//  Curry.swift
//  concorde
//
//  Created by John Connolly on 2018-06-05.
//

import Foundation

public func curry<A,B,C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in return { b in f(a,b) } }
}

public func curry<A,B,C,D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in return { b in return { c in f(a,b,c) } } }
}

public func curry<A,B,C,D,E>(_ f: @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
    return { a in return { b in return { c in return { d in f(a,b,c,d) } } } }
}

public func curry<A,B,C,D,E,F>(_ f: @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
    return { a in return { b in return { c in return { d in return { e in f(a,b,c,d,e) } } } } }
}

public func curry<A,B,C,D,E,G,H>(_ f: @escaping (A, B, C, D, E, G) -> H) -> (A) -> (B) -> (C) -> (D) -> (E) -> (G) -> H {
    return { a in return { b in return { c in return { d in return { e in { g in return f(a,b,c,d,e,g) } } } } } } 
}

