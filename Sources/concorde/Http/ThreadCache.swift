//
//  ThreadCache.swift
//  concorde
//
//  Created by John Connolly on 2018-11-11.
//

import Foundation

public final class ThreadCache {
    let items: [Any]

    init(items: [Any]) {
        self.items = items
    }

    func get<T>() -> T {
        guard let item = items.first(where: { $0 as? T != nil }) as? T else {
            fatalError("Requested resource that does not exist")
        }
        return item
    }
}
