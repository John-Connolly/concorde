//
//  Configuration.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation
import NIO

public struct Configuration {
    let port: Int
    let resources: [(EventLoopGroup) -> Any]
    public init(port: Int, resources: [(EventLoopGroup) -> Any]) {
        self.port = port
        self.resources = resources
    }
}
