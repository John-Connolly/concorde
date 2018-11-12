//
//  Future+Zip.swift
//  concorde
//
//  Created by John Connolly on 2018-11-11.
//

import Foundation
import NIO


public func zip<A, B>(_ a: Future<A>, _ b: Future<B>) -> Future<(A,B)> {
    return a.and(b)
}

public func zip<A, B, C>(_ a: Future<A>,
                  _ b: Future<B>,
                  _ c: Future<C>) -> Future<(A,B,C)> {
    return  zip(zip(a, b), c).map { ($0.0, $0.1, $1) }
}


public func zip<A, B, C, D>(_ a: Future<A>,
                  _ b: Future<B>,
                  _ c: Future<C>,
                  _ d: Future<D>) -> Future<(A,B,C,D)> {
    return  zip(zip(a, b, c), d).map { ($0.0, $0.1, $0.2, $1) }
}

public func zip<A, B, C, D, E>(_ a: Future<A>,
                     _ b: Future<B>,
                     _ c: Future<C>,
                     _ d: Future<D>,
                     _ e: Future<E>) -> Future<(A,B,C,D,E)> {
    return  zip(zip(a, b, c, d), e).map { ($0.0, $0.1, $0.2, $0.3, $1) }
}
