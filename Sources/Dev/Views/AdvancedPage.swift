////
////  AdvancedPage.swift
////  Dev
////
////  Created by John Connolly on 2019-03-20.
////
//
//import Foundation
//
//import Foundation
//import concorde
//import Html
//
//
//func advancedPage() -> Middleware {
//    return (write(status: .ok)
//        >=> write(body: renderContent(), contentType: .html))
//}
//
//
//private func renderContent() -> String {
//    return render(page.map(baseView >>> pure).view(()))
//}
//
//
//private enum Code {
//    
//    static let mainDescription = """
//                                Concorde is a functional micro framework for building web applications. Concorde will do most things out of the box but is made to have the main components of it easily switched out if necessary.  Concorde is built on top of Swift-NIO this provides the foundation for Concordes concurrency model.
//                                """
//    static let routingDescription = """
//                                    Concordes router is based on applicative parsing.  This adds a level of type safety to routing that would not be possible with alternative methods.  Below are some examples of combinators that allow you to build up routes.
//                                    """
//    
//    static let routingCode = """
//
//                            pure<A>(_ a: A) -> Route<A>
//
//                            /// Discard left value.
//                            func *> <A, B>(lhs: Route<A>, rhs: Route<B>) -> Route<B>
//
//                            /// Applicative
//                            func <*> <A, B>(lhs: Route<(A) -> B>, rhs: Route<A>) -> Route<B>
//
//                            /// Functor
//                            func <^> <A, B>(lhs: @escaping (A) -> B, rhs: Route<A>) -> Route<B>
//
//                            /// Choice
//                            func choice<A>(_ routes: [Route<A>]) -> Route<A>
//
//                            /// Path only matches if string is present
//                            func path(_ matching: String) -> Route<String>
//                            """
//    
//    static let dbDescription = """
//                             Concorde’s multi reactor architecture means that sharing objects between threads is
//                            is prohibited. This means that objects are cached per thread in a pthread specific variable. This dramatically increases performance and simplifies programming.  You can define an array functions to run on application start up, later you can access this cached objects from the current Conn.
//                            """
//    static let databases: String = """
//                         let preflightCheck: [(EventLoopGroup) -> Any] = [
//                            redisConn,
//                            swiftQConn
//                         ]
//                         """
//    
//    static let streamDescription = """
//                            Concorde streams all incoming data. This means that Concorde uses minimal memory even when dealing with large post bodies. Because of Concorde’s asynchronous architecture streams have to handle back-pressure. In short this means that streams con not read more than they can write.
//                            """
//    
//}
//
///// Broken up for the type checker
//private let architecture: View<(), [Node]> = logo.contramap(const(()))
//    <> (sectionTitle.contramap { _ in ("Advanced", nil) })
//    <> descriptionSection.contramap(const("Architecture"))
//    <> paragraphSection.contramap(const(Code.mainDescription))
//
//private let helpfulLibs: View<(), [Node]> = descriptionSection.contramap { _ in "Helpful libraries" }
//    <> (listSection.contramap { _ in
//        return [
//            ("https://github.com/pointfreeco/swift-web", "swift-web"),
//            ("https://github.com/pointfreeco/swift-html", "swift-html"),
//            ("https://github.com/John-Connolly/terse", "terse")
//        ]
//    })
//
//private let routing: View<(), [Node]> = descriptionSection.contramap(const("Routing"))
//    <> paragraphSection.contramap(const(Code.routingDescription))
//    <> codeSection.contramap(const(Code.routingCode))
//
//private let databases: View<(), [Node]> = descriptionSection.contramap(const("Databases"))
//    <> paragraphSection.contramap(const(Code.dbDescription))
//    <> codeSection.contramap(const(Code.databases))
//
//private let page: View<(), [Node]> = architecture
//    <> routing
//    <> descriptionSection.contramap(const("Composable Streams"))
//    <> paragraphSection.contramap(const(Code.streamDescription))
//    <> databases
//    <> descriptionSection.contramap(const("Web Sockets"))
//    <> paragraphSection.contramap(const("TODO"))
//    <> helpfulLibs
//    <> footerSection.contramap(const(()))
//
//
//
//
