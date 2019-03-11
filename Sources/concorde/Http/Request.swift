//
//  Request.swift
//  concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation
import NIO
import NIOHTTP1

public struct Request {
  public let head: HTTPRequestHead

  public var body: ((Data) -> ())?

  public init(head: HTTPRequestHead) {
    self.head = head
  }

  public var method: HTTPMethod {
    return head.method
  }

}
