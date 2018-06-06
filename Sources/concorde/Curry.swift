//
//  Curry.swift
//  concorde
//
//  Created by John Connolly on 2018-06-05.
//

import Foundation

func curry<A,B,C>(f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in return { b in f(a,b) } }
}

func curry<A,B,C,D>(f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in return { b in return { c in f(a,b,c) } } }
}

func curry<A,B,C,D,E>(f: @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
    return { a in return { b in return { c in return { d in f(a,b,c,d) } } } }
}

func curry<A,B,C,D,E,F>(f: @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
    return { a in return { b in return { c in return { d in return { e in f(a,b,c,d,e) } } } } }
}

func curry<A,B,C,D,E,G,H>(_ f: @escaping (A, B, C, D, E, G) -> H) -> (A) -> (B) -> (C) -> (D) -> (E) -> (G) -> H {
    return { a in return { b in return { c in return { d in return { e in { g in return f(a,b,c,d,e,g) } } } } } } 
}

