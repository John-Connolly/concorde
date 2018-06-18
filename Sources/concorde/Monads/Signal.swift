//
//  Signal.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation


enum Result<T> {
    case success(T)
    case error(Error)
}

public struct Signal<T> {

    private var observers: [(Result<T>) -> ()] = []


    func flatMapLatest() {

    }

    func mapLastest() {

    }

}
