//
//  Reader.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation

public struct Reader<E, A> {
    let g: (E) -> A

    public func apply(_ e: E) -> A {
        return g(e)
    }

    public func map<B>(f: @escaping (A) -> B) -> Reader<E, B> {
        return Reader<E, B> { e in
            f(self.g(e))
        }
    }

    public func flatMap<B>(f: @escaping (A) -> Reader<E, B>) -> Reader<E, B> {
        return Reader<E, B> { e in
            f(self.g(e)).g(e)
        }
    }
}
