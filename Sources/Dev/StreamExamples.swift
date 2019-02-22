//
//  StreamExamples.swift
//  Dev
//
//  Created by John Connolly on 2019-02-20.
//

import Foundation
import concorde

func echo() -> Middleware {
    return write(body: "Hello")
}
