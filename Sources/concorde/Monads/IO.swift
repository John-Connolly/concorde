//
//  IO.swift
//  concorde
//
//  Created by John Connolly on 2019-03-10.
//

import Foundation

struct IO<A> {

    let run: () -> Future<A>

    static func effectTotal() {

    }

}

//struct UnsafeFuture<A> {
//
//    var result: Result<A>?
//    var awaiters: [(Result<A>) -> ()] = []
//
//    init(compute: (@escaping (Result<A>) -> ()) -> ()) {
//        compute(send)
//    }
//
//    private func send(_ result: Result<A>) {
//
//    }
//}
