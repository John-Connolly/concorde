//
//  KeyValueStore.swift
//  Dev
//
//  Created by John Connolly on 2018-07-03.
//

import Foundation
import concorde

/// TEMPORARY
final class KeyValueStore<Key: Hashable, Value> {

    private var store = Dictionary<Key, Value>()

    private let booleanSemaphore = DispatchSemaphore(value: 1)

    func add(key: Key, value: Value) {
        booleanSemaphore.wait()
        store[key] = value
        booleanSemaphore.signal()
    }

    func value(key: Key) -> Value? {
        defer {
            booleanSemaphore.signal()
        }
        booleanSemaphore.wait()
        return store[key]
    }

    func all() -> [Value] {
        defer {
            booleanSemaphore.signal()
        }
        booleanSemaphore.wait()
        return store.values.map(id)
    }

}
