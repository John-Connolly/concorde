//
//  AdvancedPage.swift
//  Dev
//
//  Created by John Connolly on 2019-03-20.
//

import Foundation

import Foundation
import concorde
import Html


func advancedPage() -> Middleware {
    return (write(status: .ok)
        >=> write(body: renderContent(), contentType: .html))
}


private func renderContent() -> String {
    return render(page.map(baseView >>> pure).view(()))
}


private enum Code {
    static let dbDescription = """
                            Concordes multi reator architecture means that sharing objects between threads is
                            is prohibited. This means that objects are cached per thread in a pthread specific variable. This dramaticatly increases performance an simplifies programming.  You can define an array functions to run on application start up, later you can access this cached objects from the current Conn.
                            """
    static let databases: String = """
                         let preflightCheck: [(EventLoopGroup) -> Any] = [
                            redisConn,
                            swiftQConn
                         ]
                         """

}


private let page: View<(), [Node]> =
    (sectionTitle.contramap { _ in ("Advanced", nil) })
    <> descriptionSection.contramap { _ in "Architecture" }
    <> descriptionSection.contramap { _ in "Routing" }
    <> descriptionSection.contramap { _ in "Composable Streams" }
    <> descriptionSection.contramap { _ in "Databases" }
    <> paragraphSection.contramap { _ in Code.dbDescription }
    <> codeSection.contramap { _ in Code.databases }
    <> descriptionSection.contramap { _ in "Web Sockets" }
    <> footerSection.contramap { _ in }

