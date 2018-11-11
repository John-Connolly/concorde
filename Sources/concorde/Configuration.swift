//
//  Configuration.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation

public struct Configuration {
    let port: Int
    let resouces: [() -> Any]
    public init(port: Int) {
        self.port = port
        self.resouces = []
    }
}
