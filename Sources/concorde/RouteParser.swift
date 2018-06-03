//
//  RouteParser.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation

typealias Stream = [UInt8]
typealias Parser<A> = (Stream) -> (A, Stream)?
