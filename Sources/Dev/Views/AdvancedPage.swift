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

    static let mainDescription = """
                                Concorde is a functional micro framework for building web applications. Concorde will do most things out of the box but is made to have the main components of it easily switched out if necessary.  Concorde is built on top of Swift-NIO this provides the foundation for Concordes concurrency model.
                                """
    static let routingDescription = """
                                    Concordes router is based on applicative parsing.  This adds a level of type safety to routing that would not be possible with alternative methods.  Below are some examples of combinators that allow you to build up routes.
                                    """

    static let routingCode = """

                            pure<A>(_ a: A) -> Route<A>

                            /// Discard left value.
                            func *> <A, B>(lhs: Route<A>, rhs: Route<B>) -> Route<B>

                            /// Applicative
                            func <*> <A, B>(lhs: Route<(A) -> B>, rhs: Route<A>) -> Route<B>

                            /// Functor
                            func <^> <A, B>(lhs: @escaping (A) -> B, rhs: Route<A>) -> Route<B>

                            /// Choice
                            func choice<A>(_ routes: [Route<A>]) -> Route<A>

                            /// Path only matches if string is present
                            func path(_ matching: String) -> Route<String>
                            """

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

    static let streamDescription = """
                            Concorde streams all incomming data. This means that concorde using minimal memory even when dealling with large post bodies.  Because of Concordes asynchronous architecture streams have to handle back-pressure.  In short this means that streams connot read more than they can write.
                            """

}

/// Type was too complex to resolve
let section1: View<(), [Node]> = logo.contramap { _ in }
    <> (sectionTitle.contramap { _ in ("Advanced", nil) })
    <> descriptionSection.contramap { _ in "Architecture" }
    <> paragraphSection.contramap(const(Code.mainDescription))

private let page: View<(), [Node]> = section1
    <> descriptionSection.contramap { _ in "Routing" }
    <> paragraphSection.contramap { _ in Code.routingDescription }
    <> codeSection.contramap { _ in Code.routingCode }
    <> descriptionSection.contramap { _ in "Composable Streams" }
    <> paragraphSection.contramap { _ in Code.streamDescription }
    <> descriptionSection.contramap { _ in "Databases" }
    <> paragraphSection.contramap { _ in Code.dbDescription }
    <> codeSection.contramap { _ in Code.databases }
    <> descriptionSection.contramap { _ in "Web Sockets" }
    <> paragraphSection.contramap { _ in "TODO" }
    <> footerSection.contramap { _ in }

